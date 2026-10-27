//
//  PCRoute.swift
//  PocketCoach
//

/// Internal navigation routes within the Pocket Coach feature flow.
enum PCRoute: Hashable {
    /// Initial exercise selection menu.
    case exerciseList

    /// Real-time camera tracking session for a specific exercise.
    case liveSession(PCExercise)

    /// Workout summary breakdown.
    case summary
}
