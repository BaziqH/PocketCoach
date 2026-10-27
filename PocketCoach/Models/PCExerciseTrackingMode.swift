//
//  PCExerciseTrackingMode.swift
//  PocketCoach
//

/// Evaluation mode determining how an exercise session measures progress.
enum PCExerciseTrackingMode: String, Codable, CaseIterable, Sendable {
    /// Counts discrete completed repetitions.
    case reps

    /// Tracks a timed static hold with continuous form verification.
    case hold
}
