//
//  PCLiveSessionViewModel.swift
//  PocketCoach
//

/// View model orchestrating real-time form checking, camera lifecycle, and coaching state.
@MainActor
final class PCLiveSessionViewModel: ObservableObject {
    /// Active exercise being performed.
    let exercise: PCExercise

    /// Count of completed valid repetitions.
    @Published private(set) var repCount: Int = 0

    /// Current real-time camera tracking quality classification.
    @Published private(set) var trackingQuality: PCTrackingQuality = .good

    /// Normalized positions and statuses of all detected skeletal joints.
    @Published private(set) var jointStates: [PCJointState] = []

    /// Current coaching cue message displayed to the athlete.
    @Published private(set) var currentCue: String?

    /// Visibility flag for the body silhouette alignment guide.
    @Published private(set) var isPositioningGuideVisible: Bool = true

    /// Camera hardware authorization status.
    @Published private(set) var cameraPermissionStatus: PCCameraPermissionStatus = .notDetermined

    /// Real-time camera hardware lifecycle state.
    @Published private(set) var cameraState: PCCameraState = .idle

    /// Indicates whether the active workout session is paused (e.g. app backgrounded).
    @Published private(set) var isPaused: Bool = false

    /// Injected camera service abstraction.
    let cameraService: PCCameraService

    #if DEBUG
    /// Diagnostic metrics presented on the live screen during debug builds.
    @Published private(set) var debugMetrics = PCCameraDebugMetrics()
    private var debugTask: Task<Void, Never>?
    #endif

    private let engine: PCFormEngine
    private let permissionService: PCCameraPermissionServicing

    private var updatesTask: Task<Void, Never>?
    private var cueDismissalTask: Task<Void, Never>?
    private var positioningDismissalTask: Task<Void, Never>?

    private var lastCueDisplayTime: Date?
    private let minimumCueDuration: TimeInterval
    private let positioningDismissDelay: TimeInterval

    /// Initializes live session with default camera permission service and timing constants.
    @MainActor
    convenience init(
        exercise: PCExercise,
        engine: PCFormEngine,
        cameraService: PCCameraService
    ) {
        self.init(
            exercise: exercise,
            engine: engine,
            cameraService: cameraService,
            permissionService: PCCameraPermissionService(),
            minimumCueDuration: PCConstants.minCueDisplayDuration,
            positioningDismissDelay: PCConstants.positioningGuideDismissDelay
        )
    }

    /// Initializes live session for an exercise, automatically selecting mock camera in simulator and physical camera on device.
    @MainActor
    convenience init(
        exercise: PCExercise,
        engine: PCFormEngine? = nil
    ) {
        let selectedEngine = engine ?? PCMockFormEngine(exercise: exercise)
        let selectedCamera: PCCameraService
        #if targetEnvironment(simulator)
        selectedCamera = PCMockCameraService()
        #else
        selectedCamera = PCAVCameraService()
        #endif

        self.init(
            exercise: exercise,
            engine: selectedEngine,
            cameraService: selectedCamera
        )
    }

    /// Designated initializer with explicit dependencies for testing and custom configurations.
    @MainActor
    init(
        exercise: PCExercise,
        engine: PCFormEngine,
        cameraService: PCCameraService,
        permissionService: PCCameraPermissionServicing,
        minimumCueDuration: TimeInterval = 2.0,
        positioningDismissDelay: TimeInterval = 1.0
    ) {
        self.exercise = exercise
        self.engine = engine
        self.cameraService = cameraService
        self.permissionService = permissionService
        self.minimumCueDuration = minimumCueDuration
        self.positioningDismissDelay = positioningDismissDelay

        setupCameraServiceCallbacks()
    }

    deinit {
        updatesTask?.cancel()
        cueDismissalTask?.cancel()
        positioningDismissalTask?.cancel()
        #if DEBUG
        debugTask?.cancel()
        #endif
    }

    /// Prepares session on screen appearance, verifies camera access, and starts capture.
    func onAppear() async {
        cameraPermissionStatus = permissionService.status

        if cameraPermissionStatus == .notDetermined {
            let granted = await permissionService.requestPermission()
            cameraPermissionStatus = granted ? .authorized : .denied
        }

        guard cameraPermissionStatus == .authorized else {
            cameraState = .failed(.permissionDenied)
            return
        }

        cameraState = .starting
        do {
            try await cameraService.start()
            cameraState = .running
            #if DEBUG
            startDebugFrameProcessing()
            #endif
            await startEngine()
            startSetupTipTimer()
        } catch let error as PCCameraError {
            cameraState = .failed(error)
        } catch {
            cameraState = .failed(.configurationFailed)
        }
    }

    /// Handles screen disappearance or cleanup.
    func onDisappear() async {
        updatesTask?.cancel()
        updatesTask = nil
        cueDismissalTask?.cancel()
        cueDismissalTask = nil
        positioningDismissalTask?.cancel()
        positioningDismissalTask = nil
        #if DEBUG
        debugTask?.cancel()
        debugTask = nil
        #endif
        await cameraService.stop()
        cameraState = .idle
    }

    /// Manually dismisses the positioning guide overlay on user tap.
    func dismissPositioningGuide() {
        positioningDismissalTask?.cancel()
        positioningDismissalTask = nil
        isPositioningGuideVisible = false
    }

    /// Flips between front and back camera inputs.
    func flipCamera() async {
        do {
            try await cameraService.switchCamera()
            #if DEBUG
            debugMetrics.position = cameraService.position
            #endif
        } catch let error as PCCameraError {
            cameraState = .failed(error)
        } catch {
            cameraState = .failed(.configurationFailed)
        }
    }

    /// Pauses session operations when the host application resigns active state.
    func pause() {
        isPaused = true
        Task { [weak self] in
            await self?.cameraService.stop()
            self?.cameraState = .idle
        }
    }

    /// Resumes active camera analysis when the application returns to foreground.
    func resume() {
        isPaused = false
        if cameraPermissionStatus == .authorized {
            Task { [weak self] in
                guard let self = self else { return }
                self.cameraState = .starting
                do {
                    try await self.cameraService.start()
                    self.cameraState = .running
                } catch let error as PCCameraError {
                    self.cameraState = .failed(error)
                } catch {
                    self.cameraState = .failed(.configurationFailed)
                }
            }
        }
    }

    /// Stops engine tracking and compiles final session metrics.
    func finishSession() async -> PCSessionResult {
        updatesTask?.cancel()
        updatesTask = nil
        cueDismissalTask?.cancel()
        cueDismissalTask = nil
        positioningDismissalTask?.cancel()
        positioningDismissalTask = nil
        #if DEBUG
        debugTask?.cancel()
        debugTask = nil
        #endif

        await cameraService.stop()
        cameraState = .idle
        return await engine.stop()
    }

    private func setupCameraServiceCallbacks() {
        if let avService = cameraService as? PCAVCameraService {
            avService.onInterruptionChanged = { [weak self] isInterrupted in
                guard let self = self else { return }
                self.cameraState = isInterrupted ? .interrupted : .running
            }
            avService.onError = { [weak self] error in
                guard let self = self else { return }
                self.cameraState = .failed(error)
            }
        } else if let mockService = cameraService as? PCMockCameraService {
            mockService.onInterruptionChanged = { [weak self] isInterrupted in
                guard let self = self else { return }
                self.cameraState = isInterrupted ? .interrupted : .running
            }
            mockService.onError = { [weak self] error in
                guard let self = self else { return }
                self.cameraState = .failed(error)
            }
        }
    }

    private func startEngine() async {
        do {
            try await engine.start()
        } catch {
            return
        }

        updatesTask?.cancel()
        updatesTask = Task { [weak self] in
            guard let self = self else { return }
            for await update in self.engine.updates {
                if Task.isCancelled { break }
                self.process(update: update)
            }
        }
    }

    private func process(update: PCFormUpdate) {
        guard !isPaused else { return }
        // Pause camera tracking updates until the initial 2-3s setup tip popup is dismissed
        guard !isPositioningGuideVisible else { return }

        self.repCount = update.repCount
        self.trackingQuality = update.trackingQuality

        // If tracking is poor, normalize all joint feedback states to neutral
        if update.trackingQuality.isGood {
            self.jointStates = update.jointStates
        } else {
            self.jointStates = update.jointStates.map { joint in
                PCJointState(name: joint.name, x: joint.x, y: joint.y, status: .neutral)
            }
        }

        handleCueUpdate(update.currentCue)
    }

    /// Schedules automatic dismissal of the initial camera setup popup after 2.5 seconds.
    private func startSetupTipTimer() {
        positioningDismissalTask?.cancel()
        positioningDismissalTask = Task { [weak self] in
            guard let self = self else { return }
            try? await Task.sleep(nanoseconds: 2_500_000_000)
            if !Task.isCancelled {
                self.dismissPositioningGuide()
            }
        }
    }

    private func handleCueUpdate(_ newCue: String?) {
        guard newCue != currentCue else { return }

        let now = Date()
        let elapsed = lastCueDisplayTime.map { now.timeIntervalSince($0) } ?? minimumCueDuration

        if elapsed >= minimumCueDuration {
            cueDismissalTask?.cancel()
            cueDismissalTask = nil
            currentCue = newCue
            lastCueDisplayTime = (newCue != nil) ? now : nil
        } else if cueDismissalTask == nil {
            let remaining = minimumCueDuration - elapsed
            cueDismissalTask = Task { [weak self] in
                guard let self = self else { return }
                let nanoseconds = UInt64(remaining * 1_000_000_000)
                try? await Task.sleep(nanoseconds: nanoseconds)

                if !Task.isCancelled {
                    self.currentCue = newCue
                    self.lastCueDisplayTime = (newCue != nil) ? Date() : nil
                }
                self.cueDismissalTask = nil
            }
        }
    }

    #if DEBUG
    private func startDebugFrameProcessing() {
        debugTask?.cancel()
        debugTask = Task { [weak self] in
            guard let self = self else { return }
            var previousTimestamp: TimeInterval?

            for await frame in self.cameraService.frames {
                if Task.isCancelled { break }
                let width = CVPixelBufferGetWidth(frame.pixelBuffer)
                let height = CVPixelBufferGetHeight(frame.pixelBuffer)
                var currentFps = self.debugMetrics.fps
                var dropped = self.debugMetrics.droppedFrames

                if let prev = previousTimestamp {
                    let delta = frame.timestamp - prev
                    if delta > 0.001 {
                        let instantFps = 1.0 / delta
                        currentFps = (currentFps > 0) ? (currentFps * 0.8 + instantFps * 0.2) : instantFps
                        if delta > 0.055 {
                            dropped += max(1, Int((delta - 0.033) / 0.033))
                        }
                    }
                }
                previousTimestamp = frame.timestamp

                self.debugMetrics = PCCameraDebugMetrics(
                    fps: currentFps,
                    droppedFrames: dropped,
                    frameWidth: width,
                    frameHeight: height,
                    position: self.cameraService.position
                )
            }
        }
    }
    #endif
}
