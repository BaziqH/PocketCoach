//
//  PCAVCameraService.swift
//  PocketCoach
//

/// Production AVFoundation camera service streaming 720p/30fps unmirrored portrait frames.
final class PCAVCameraService: NSObject, PCCameraService, AVCaptureVideoDataOutputSampleBufferDelegate {
    private let session = AVCaptureSession()
    private let videoDataOutput = AVCaptureVideoDataOutput()
    private var activeDeviceInput: AVCaptureDeviceInput?
    private var currentPosition: PCCameraPosition = .front
    private var isConfigured = false

    // Dedicated serial queue required by Apple AVFoundation for AVCaptureSession configuration and video output delegate callbacks.
    private let sessionQueue = DispatchQueue(label: "com.pocketcoach.camera.sessionQueue")

    private var frameContinuation: AsyncStream<PCCameraFrame>.Continuation?
    private var currentStream: AsyncStream<PCCameraFrame>?

    /// Callback invoked when session interruption status changes.
    var onInterruptionChanged: ((Bool) -> Void)?

    /// Callback invoked when a hardware or runtime capture error occurs.
    var onError: ((PCCameraError) -> Void)?

    /// Underlying capture session used by AVCaptureVideoPreviewLayer.
    var captureSession: AVCaptureSession? {
        session
    }

    /// Current active camera lens position.
    var position: PCCameraPosition {
        currentPosition
    }

    /// Continuous frame stream delivering latest camera frames with drop-late policy.
    var frames: AsyncStream<PCCameraFrame> {
        if let existing = currentStream {
            return existing
        }
        let stream = AsyncStream(PCCameraFrame.self, bufferingPolicy: .bufferingNewest(1)) { [weak self] continuation in
            self?.frameContinuation = continuation
        }
        self.currentStream = stream
        return stream
    }

    override init() {
        super.init()
        setupInterruptionObservers()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        frameContinuation?.finish()
    }

    /// Starts capture session asynchronously on dedicated background queue.
    func start() async throws {
        // Prepare fresh stream if previously stopped
        _ = frames

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            sessionQueue.async { [weak self] in
                guard let self = self else {
                    continuation.resume(throwing: PCCameraError.noCameraAvailable)
                    return
                }

                do {
                    try self.configureSessionIfNeeded()
                    if !self.session.isRunning {
                        self.session.startRunning()
                    }
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    /// Halts capture session and finishes the frame stream.
    func stop() async {
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            sessionQueue.async { [weak self] in
                guard let self = self else {
                    continuation.resume()
                    return
                }

                if self.session.isRunning {
                    self.session.stopRunning()
                }
                self.frameContinuation?.finish()
                self.frameContinuation = nil
                self.currentStream = nil
                continuation.resume()
            }
        }
    }

    /// Switches between front and back physical cameras.
    func switchCamera() async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            sessionQueue.async { [weak self] in
                guard let self = self else {
                    continuation.resume(throwing: PCCameraError.noCameraAvailable)
                    return
                }

                let targetPosition: PCCameraPosition = (self.currentPosition == .front) ? .back : .front
                do {
                    try self.setCameraPosition(targetPosition)
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    // MARK: - Configuration

    private func configureSessionIfNeeded() throws {
        guard !isConfigured else { return }

        session.beginConfiguration()
        defer { session.commitConfiguration() }

        // Prefer 720p HD, fallback to high
        if session.canSetSessionPreset(.hd1280x720) {
            session.sessionPreset = .hd1280x720
        } else {
            session.sessionPreset = .high
        }

        // Attach initial camera input
        try attachCameraInput(for: currentPosition)

        // Configure video data output
        videoDataOutput.alwaysDiscardsLateVideoFrames = true
        videoDataOutput.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)
        ]
        videoDataOutput.setSampleBufferDelegate(self, queue: sessionQueue)

        guard session.canAddOutput(videoDataOutput) else {
            throw PCCameraError.configurationFailed
        }
        session.addOutput(videoDataOutput)

        // Configure video orientation and ensure data connection is unmirrored
        if let connection = videoDataOutput.connection(with: .video) {
            if connection.isVideoOrientationSupported {
                connection.videoOrientation = .portrait
            }
            if connection.isVideoMirroringSupported {
                connection.isVideoMirrored = false
            }
        }

        isConfigured = true
    }

    private func setCameraPosition(_ targetPosition: PCCameraPosition) throws {
        session.beginConfiguration()
        defer { session.commitConfiguration() }

        if let existingInput = activeDeviceInput {
            session.removeInput(existingInput)
            activeDeviceInput = nil
        }

        try attachCameraInput(for: targetPosition)
        currentPosition = targetPosition

        if let connection = videoDataOutput.connection(with: .video) {
            if connection.isVideoOrientationSupported {
                connection.videoOrientation = .portrait
            }
            if connection.isVideoMirroringSupported {
                connection.isVideoMirrored = false
            }
        }
    }

    private func attachCameraInput(for targetPosition: PCCameraPosition) throws {
        let captureDevicePosition: AVCaptureDevice.Position = (targetPosition == .front) ? .front : .back
        guard let device = findDevice(for: captureDevicePosition) else {
            throw PCCameraError.noCameraAvailable
        }

        // Configure 30 fps
        do {
            try device.lockForConfiguration()
            device.activeVideoMinFrameDuration = CMTime(value: 1, timescale: 30)
            device.activeVideoMaxFrameDuration = CMTime(value: 1, timescale: 30)
            device.unlockForConfiguration()
        } catch {
            // Keep device defaults if frame duration lock fails
        }

        guard let input = try? AVCaptureDeviceInput(device: device), session.canAddInput(input) else {
            throw PCCameraError.configurationFailed
        }

        session.addInput(input)
        self.activeDeviceInput = input
    }

    private func findDevice(for position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let discovery = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera],
            mediaType: .video,
            position: position
        )
        return discovery.devices.first
    }

    // MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let timestamp = CMTimeGetSeconds(CMSampleBufferGetPresentationTimeStamp(sampleBuffer))
        let isFront = (currentPosition == .front)

        let frame = PCCameraFrame(
            pixelBuffer: pixelBuffer,
            timestamp: timestamp,
            isMirrored: isFront
        )
        frameContinuation?.yield(frame)
    }

    // MARK: - Interruption & Error Handling

    private func setupInterruptionObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleSessionWasInterrupted),
            name: .AVCaptureSessionWasInterrupted,
            object: session
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleSessionInterruptionEnded),
            name: .AVCaptureSessionInterruptionEnded,
            object: session
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleSessionRuntimeError),
            name: .AVCaptureSessionRuntimeError,
            object: session
        )
    }

    @objc private func handleSessionWasInterrupted(notification: Notification) {
        DispatchQueue.main.async { [weak self] in
            self?.onInterruptionChanged?(true)
        }
    }

    @objc private func handleSessionInterruptionEnded(notification: Notification) {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            if !self.session.isRunning {
                self.session.startRunning()
            }
            DispatchQueue.main.async {
                self.onInterruptionChanged?(false)
            }
        }
    }

    @objc private func handleSessionRuntimeError(notification: Notification) {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            if !self.session.isRunning {
                self.session.startRunning()
            }
            DispatchQueue.main.async {
                self.onError?(PCCameraError.interrupted)
            }
        }
    }
}
