//
//  PCSessionResult.swift
//  PocketCoach
//

/// Completed workout session data returned to the host application.
struct PCSessionResult: Equatable, Sendable, Hashable {
    /// The exercise performed during this session.
    let exercise: PCExercise

    /// Total count of successfully completed repetitions.
    let completedReps: Int

    /// Repetitions flagged with form errors during execution.
    let repsWithErrors: Int

    /// Most frequent form correction advice given, or nil if no errors occurred.
    let mostCommonError: String?

    /// Duration of the active session in seconds.
    let duration: TimeInterval
}
