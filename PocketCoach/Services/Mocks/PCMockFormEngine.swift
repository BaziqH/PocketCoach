//
//  PCMockFormEngine.swift
//  PocketCoach
//

/// Mock form engine emitting realistic simulated reps, skeleton poses, and cues for tests and previews.
final class PCMockFormEngine: PCFormEngine {
    private let exercise: PCExercise
    private var continuation: AsyncStream<PCFormUpdate>.Continuation?
    private var simulationTask: Task<Void, Never>?
    private var currentRepCount: Int = 0
    private var repsWithErrorsCount: Int = 1
    private var startTime: Date = Date()

    /// Predefined canned updates for deterministic unit testing.
    var cannedUpdates: [PCFormUpdate]?

    /// Predefined result to return upon stopping.
    var cannedResult: PCSessionResult?

    /// Initializes mock engine configured for an exercise.
    init(exercise: PCExercise, cannedUpdates: [PCFormUpdate]? = nil, cannedResult: PCSessionResult? = nil) {
        self.exercise = exercise
        self.cannedUpdates = cannedUpdates
        self.cannedResult = cannedResult
    }

    /// Asynchronous stream yielding simulated form tracking updates.
    lazy var updates: AsyncStream<PCFormUpdate> = {
        AsyncStream { [weak self] continuation in
            self?.continuation = continuation
        }
    }()

    func start() async throws {
        startTime = Date()
        currentRepCount = 0

        if let canned = cannedUpdates {
            for update in canned {
                continuation?.yield(update)
            }
            return
        }

        startSimulation()
    }

    func stop() async -> PCSessionResult {
        simulationTask?.cancel()
        simulationTask = nil
        continuation?.finish()

        if let cannedResult = cannedResult {
            return cannedResult
        }

        let elapsed = max(1.0, Date().timeIntervalSince(startTime))
        return PCSessionResult(
            exercise: exercise,
            completedReps: max(currentRepCount, 8),
            repsWithErrors: repsWithErrorsCount,
            mostCommonError: NSLocalizedString("pc_cue_chest_up", tableName: "PocketCoach", bundle: .main, value: "Keep chest lifted", comment: ""),
            duration: elapsed
        )
    }

    private func startSimulation() {
        simulationTask?.cancel()
        simulationTask = Task { [weak self] in
            guard let self = self else { return }

            // Phase 1: Positioning alignment
            let initialJoints = self.generateSkeleton(depth: 0.05)
            self.continuation?.yield(PCFormUpdate(
                repCount: 0,
                trackingQuality: .good,
                jointStates: initialJoints,
                currentCue: nil
            ))

            try? await Task.sleep(nanoseconds: 1_200_000_000)
            if Task.isCancelled { return }

            var cycle: Double = 0.0
            var tick: Int = 0

            while !Task.isCancelled {
                tick += 1
                cycle += 0.25
                let depth = (sin(cycle) + 1.0) / 2.0

                if depth > 0.95 && (tick % 10 == 0) {
                    self.currentRepCount += 1
                }

                let currentCue: String?
                let jointStatus: PCJointFeedbackStatus
                if depth > 0.85 && tick % 20 < 10 {
                    currentCue = NSLocalizedString("pc_cue_chest_up", tableName: "PocketCoach", bundle: .main, value: "Keep chest lifted", comment: "")
                    jointStatus = .error
                } else {
                    currentCue = nil
                    jointStatus = .good
                }

                let joints = self.generateSkeleton(depth: depth, status: jointStatus)
                self.continuation?.yield(PCFormUpdate(
                    repCount: self.currentRepCount,
                    trackingQuality: .good,
                    jointStates: joints,
                    currentCue: currentCue
                ))

                try? await Task.sleep(nanoseconds: 120_000_000)
            }
        }
    }

    private var isHorizontalPosture: Bool {
        exercise.id == "pushup"
            || exercise.id == "plank"
            || exercise.trackingMode == .hold
            || exercise.targetAngles.contains(.bodyLine)
            || exercise.targetAngles.contains(.hipSag)
    }

    private var isSplitStancePosture: Bool {
        exercise.id == "lunge"
            || exercise.targetAngles.contains(.frontKnee)
            || exercise.targetAngles.contains(.rearKnee)
    }

    private func generateSkeleton(depth: Double, status: PCJointFeedbackStatus = .good) -> [PCJointState] {
        let allJoints: [PCJointState]
        if isHorizontalPosture {
            allJoints = generateHorizontalPose(depth: depth, status: status)
        } else if isSplitStancePosture {
            allJoints = generateLungePose(depth: depth, status: status)
        } else {
            allJoints = generateSquatPose(depth: depth, status: status)
        }

        var activeNames = Set<PCJointName>()
        for angle in exercise.targetAngles {
            let parts: [PCJointPart]
            switch angle.definition {
            case .threePoint(let first, let middle, let last),
                 .lineOffset(let first, let middle, let last):
                parts = [first, middle, last]
            case .fromVertical(let first, let second):
                parts = [first, second]
            }

            let sides = resolvedSides(for: angle.sideRule)
            for part in parts {
                // In side view, shared torso/pelvis joints (shoulder, hip) only show a single point,
                // whereas split-stance leg joints (knee, ankle) show front (.left) and rear (.right) legs.
                if exercise.cameraView == .side && (part == .shoulder || part == .hip || part == .elbow || part == .wrist) {
                    activeNames.insert(PCJointName.joint(part, .left))
                } else {
                    for side in sides {
                        activeNames.insert(PCJointName.joint(part, side))
                    }
                }
            }
        }

        guard !activeNames.isEmpty else {
            if exercise.cameraView == .side {
                let defaultSideJoints: Set<PCJointName> = [.leftShoulder, .leftHip, .leftKnee, .leftAnkle]
                return allJoints.filter { defaultSideJoints.contains($0.name) }
            }
            return allJoints
        }
        return allJoints.filter { activeNames.contains($0.name) }
    }

    private func resolvedSides(for sideRule: PCSideRule) -> [PCBodySide] {
        guard exercise.cameraView == .side else {
            return PCBodySide.allCases
        }
        switch sideRule {
        case .bestConfidence, .frontLeg:
            return [.left]
        case .rearLeg:
            return [.right]
        }
    }

    private func generateSquatPose(depth: Double, status: PCJointFeedbackStatus) -> [PCJointState] {
        let hipY = 0.50 + (depth * 0.14)
        let shoulderY = 0.28 + (depth * 0.10)
        let kneeXShift = depth * 0.06

        return [
            PCJointState(name: .nose, x: 0.46, y: 0.18 + (depth * 0.08), status: .good),
            PCJointState(name: .neck, x: 0.48, y: 0.23 + (depth * 0.09), status: .good),
            PCJointState(name: .root, x: 0.53, y: hipY, status: .good),
            PCJointState(name: .leftEar, x: 0.47, y: 0.18 + (depth * 0.08), status: .good),
            PCJointState(name: .rightEar, x: 0.51, y: 0.18 + (depth * 0.08), status: .good),
            PCJointState(name: .leftShoulder, x: 0.48, y: shoulderY, status: status),
            PCJointState(name: .rightShoulder, x: 0.54, y: shoulderY, status: status),
            PCJointState(name: .leftElbow, x: 0.44, y: shoulderY + 0.12, status: status),
            PCJointState(name: .rightElbow, x: 0.58, y: shoulderY + 0.12, status: status),
            PCJointState(name: .leftWrist, x: 0.40, y: shoulderY + 0.20, status: .good),
            PCJointState(name: .rightWrist, x: 0.60, y: shoulderY + 0.20, status: .good),
            PCJointState(name: .leftHip, x: 0.52 + (depth * 0.03), y: hipY, status: status),
            PCJointState(name: .rightHip, x: 0.56 + (depth * 0.03), y: hipY, status: status),
            PCJointState(name: .leftKnee, x: 0.46 - kneeXShift, y: 0.70 + (depth * 0.03), status: status),
            PCJointState(name: .rightKnee, x: 0.56 + kneeXShift, y: 0.70 + (depth * 0.03), status: status),
            PCJointState(name: .leftAnkle, x: 0.50, y: 0.88, status: status),
            PCJointState(name: .rightAnkle, x: 0.56, y: 0.88, status: status)
        ]
    }

    private func generateLungePose(depth: Double, status: PCJointFeedbackStatus) -> [PCJointState] {
        // Split stance: torso upright at x = 0.50, front leg (.left) stepped forward to x = 0.34,
        // rear leg (.right) extended back with knee dropping toward the floor at x = 0.58 and ankle at x = 0.74.
        let drop = depth * 0.14
        let shoulderY = 0.27 + drop
        let hipY = 0.51 + drop
        let frontKneeX = 0.36 - (depth * 0.03)
        let frontKneeY = 0.66 + (depth * 0.03)
        let rearKneeY = 0.68 + (depth * 0.12)

        return [
            PCJointState(name: .nose, x: 0.48, y: shoulderY - 0.10, status: .good),
            PCJointState(name: .neck, x: 0.50, y: shoulderY - 0.05, status: .good),
            PCJointState(name: .root, x: 0.50, y: hipY, status: .good),
            PCJointState(name: .leftEar, x: 0.49, y: shoulderY - 0.10, status: .good),
            PCJointState(name: .rightEar, x: 0.51, y: shoulderY - 0.10, status: .good),
            PCJointState(name: .leftShoulder, x: 0.50, y: shoulderY, status: status),
            PCJointState(name: .rightShoulder, x: 0.50, y: shoulderY, status: status),
            PCJointState(name: .leftElbow, x: 0.48, y: shoulderY + 0.12, status: .good),
            PCJointState(name: .rightElbow, x: 0.52, y: shoulderY + 0.12, status: .good),
            PCJointState(name: .leftWrist, x: 0.45, y: shoulderY + 0.20, status: .good),
            PCJointState(name: .rightWrist, x: 0.55, y: shoulderY + 0.20, status: .good),
            PCJointState(name: .leftHip, x: 0.50, y: hipY, status: status),
            PCJointState(name: .rightHip, x: 0.50, y: hipY, status: status),
            PCJointState(name: .leftKnee, x: frontKneeX, y: frontKneeY, status: status),
            PCJointState(name: .rightKnee, x: 0.58, y: rearKneeY, status: status),
            PCJointState(name: .leftAnkle, x: 0.34, y: 0.88, status: .good),
            PCJointState(name: .rightAnkle, x: 0.74, y: 0.86, status: .good)
        ]
    }

    private func generateHorizontalPose(depth: Double, status: PCJointFeedbackStatus) -> [PCJointState] {
        // Horizontal body line from shoulder (x = 0.24) -> hip (x = 0.48) -> knee (x = 0.66) -> ankle (x = 0.82),
        // with supporting elbow and wrist planted beneath the shoulder.
        let isHold = (exercise.trackingMode == .hold)
        let shoulderDrop = isHold ? 0.0 : (depth * 0.12)
        let hipSagOffset = (status == .error) ? 0.07 : (isHold ? 0.01 * depth : shoulderDrop * 0.65)

        let shoulderY = 0.56 + shoulderDrop
        let hipY = 0.60 + hipSagOffset
        let kneeY = 0.65 + (hipSagOffset * 0.5)
        let ankleY = 0.70

        let elbowX = isHold ? 0.24 : (0.29 + depth * 0.03)
        let elbowY = isHold ? 0.70 : (0.63 + depth * 0.04)

        return [
            PCJointState(name: .nose, x: 0.16, y: shoulderY - 0.01, status: .good),
            PCJointState(name: .neck, x: 0.20, y: shoulderY, status: .good),
            PCJointState(name: .root, x: 0.48, y: hipY, status: .good),
            PCJointState(name: .leftEar, x: 0.18, y: shoulderY - 0.02, status: .good),
            PCJointState(name: .rightEar, x: 0.18, y: shoulderY - 0.01, status: .good),
            PCJointState(name: .leftShoulder, x: 0.24, y: shoulderY, status: status),
            PCJointState(name: .rightShoulder, x: 0.24, y: shoulderY, status: status),
            PCJointState(name: .leftElbow, x: elbowX, y: elbowY, status: status),
            PCJointState(name: .rightElbow, x: elbowX, y: elbowY, status: status),
            PCJointState(name: .leftWrist, x: 0.22, y: 0.72, status: .good),
            PCJointState(name: .rightWrist, x: 0.22, y: 0.72, status: .good),
            PCJointState(name: .leftHip, x: 0.48, y: hipY, status: status),
            PCJointState(name: .rightHip, x: 0.48, y: hipY, status: status),
            PCJointState(name: .leftKnee, x: 0.66, y: kneeY, status: status),
            PCJointState(name: .rightKnee, x: 0.66, y: kneeY, status: status),
            PCJointState(name: .leftAnkle, x: 0.82, y: ankleY, status: status),
            PCJointState(name: .rightAnkle, x: 0.82, y: ankleY, status: status)
        ]
    }
}
