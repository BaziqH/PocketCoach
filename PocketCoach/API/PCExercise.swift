//
//  PCExercise.swift
//  PocketCoach
//

/// Domain model representing an exercise supported by Pocket Coach.
struct PCExercise: Identifiable, Codable, Equatable, Hashable, Sendable {
    /// Unique identifier for the exercise.
    let id: String

    /// User-visible name of the exercise (e.g. "Squats").
    let name: String

    /// SF Symbol icon name used for card representation.
    let systemImageName: String

    /// Recommended camera viewing perspective for accurate form tracking.
    let cameraView: PCCameraView

    /// Progress evaluation mode (repetition counting or timed static hold).
    let trackingMode: PCExerciseTrackingMode

    /// Brief coaching prompt or positioning guidance.
    let instructions: String

    /// Key anatomical angles and alignments evaluated for this movement.
    let targetAngles: [PCAngleType]

    /// Initializes exercise model with explicit attributes.
    init(
        id: String,
        name: String,
        systemImageName: String,
        cameraView: PCCameraView,
        trackingMode: PCExerciseTrackingMode = .reps,
        instructions: String,
        targetAngles: [PCAngleType] = []
    ) {
        self.id = id
        self.name = name
        self.systemImageName = systemImageName
        self.cameraView = cameraView
        self.trackingMode = trackingMode
        self.instructions = instructions
        self.targetAngles = targetAngles
    }

    /// Static catalog of exercises supported by Pocket Coach (MVP).
    @MainActor
    static let all: [PCExercise] = [
        PCExercise(
            id: "squat",
            name: "Bodyweight Squats",
            systemImageName: "figure.strengthtraining.traditional",
            cameraView: .side,
            trackingMode: .reps,
            instructions: "Place the phone at hip height, a few steps away, and stand side-on. Keep your chest up and sit back until your thighs are about parallel to the floor.",
            targetAngles: [.knee, .hip, .torsoLean]
        ),
        PCExercise(
            id: "pushup",
            name: "Standard Push-ups",
            systemImageName: "figure.core.training",
            cameraView: .side,
            trackingMode: .reps,
            instructions: "Place the phone on the floor beside you at hip height with your whole body in frame. Hold a straight line from head to heels and lower until your elbows reach about 90 degrees.",
            targetAngles: [.elbow, .bodyLine, .hipSag]
        ),
        PCExercise(
            id: "lunge",
            name: "Forward Lunges",
            systemImageName: "figure.walk",
            cameraView: .side,
            trackingMode: .reps,
            instructions: "Place the phone side-on at hip height with room to step. Step forward, lower until both knees bend to about 90 degrees, and keep your torso upright.",
            targetAngles: [.frontKnee, .rearKnee, .hip, .torsoLean]
        ),
        PCExercise(
            id: "plank",
            name: "Forearm Plank",
            systemImageName: "figure.cross.training",
            cameraView: .side,
            trackingMode: .hold,
            instructions: "Place the phone on the floor beside you at hip height. Rest on your forearms with elbows under your shoulders and hold a straight line from head to heels.",
            targetAngles: [.bodyLine, .hipSag, .knee, .upperArmLean]
        )
    ]
}
