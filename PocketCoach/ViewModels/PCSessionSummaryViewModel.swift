//
//  PCSessionSummaryViewModel.swift
//  PocketCoach
//

/// View model formatting and presenting workout performance statistics.
@MainActor
final class PCSessionSummaryViewModel: ObservableObject {
    /// Workout metrics and metadata compiled at the end of the session.
    let result: PCSessionResult

    /// Whether the athlete is permitted to pick another exercise (hidden if exercise was preset by host).
    let canChangeExercise: Bool

    /// Formatted exercise title.
    var exerciseName: String {
        result.exercise.name
    }

    /// Total reps executed.
    var totalRepsText: String {
        "\(result.completedReps)"
    }

    /// Repetitions executed with optimal form without warnings.
    var cleanRepsText: String {
        let clean = max(0, result.completedReps - result.repsWithErrors)
        return "\(clean)"
    }

    /// Repetitions flagged with form deviations.
    var formErrorsText: String {
        "\(result.repsWithErrors)"
    }

    /// Form error diagnosis or congratulatory badge.
    var mostCommonErrorText: String {
        if let error = result.mostCommonError, !error.isEmpty {
            return error
        }
        return NSLocalizedString("pc_summary_no_errors", tableName: "PocketCoach", bundle: .main, value: "No errors detected! Great form!", comment: "")
    }

    /// Cleanly formatted session duration string (mm:ss).
    var formattedDuration: String {
        let totalSeconds = Int(result.duration)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    /// Initializes summary view model with session metrics.
    init(result: PCSessionResult, canChangeExercise: Bool) {
        self.result = result
        self.canChangeExercise = canChangeExercise
    }
}
