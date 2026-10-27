//
//  PCCoordinator.swift
//  PocketCoach
//

/// Central navigation coordinator driving the stack-based feature flow.
@MainActor
final class PCCoordinator: ObservableObject {
    /// Controls presentation of the live session screen.
    @Published var isLiveSessionActive: Bool = false

    /// Controls presentation of the session summary screen.
    @Published var isSummaryActive: Bool = false

    /// Exercise currently selected for the live workout.
    @Published var selectedExercise: PCExercise?

    /// Completed session results passed into the summary screen.
    @Published var sessionResult: PCSessionResult?

    /// Flag indicating whether the exercise was fixed by the host entry point.
    let initialExerciseProvided: Bool

    /// Host callback invoked when the user exits or finishes the experience.
    let onFinish: (PCSessionResult?) -> Void

    /// Indicates whether changing exercise is permitted in the summary view.
    var canChangeExercise: Bool {
        !initialExerciseProvided
    }

    /// Initializes the navigation coordinator.
    init(initialExercise: PCExercise?, onFinish: @escaping (PCSessionResult?) -> Void) {
        self.selectedExercise = initialExercise
        self.initialExerciseProvided = initialExercise != nil
        self.onFinish = onFinish

        if initialExercise != nil {
            self.isLiveSessionActive = true
        }
    }

    /// Starts a live tracking session for a specific exercise.
    func startLiveSession(exercise: PCExercise) {
        self.selectedExercise = exercise
        self.isLiveSessionActive = true
        self.isSummaryActive = false
    }

    /// Transitions to the summary view with compiled metrics.
    func showSummary(result: PCSessionResult) {
        self.sessionResult = result
        self.isSummaryActive = true
    }

    /// Re-starts another set of the current exercise.
    func repeatExercise() {
        self.sessionResult = nil
        self.isSummaryActive = false
    }

    /// Returns to the exercise catalog.
    func returnToExerciseList() {
        guard canChangeExercise else { return }
        self.sessionResult = nil
        self.isSummaryActive = false
        self.isLiveSessionActive = false
        self.selectedExercise = nil
    }

    /// Exits the experience without recording a session.
    func dismiss() {
        onFinish(nil)
    }

    /// Exits the experience returning the final completed session result.
    func complete() {
        onFinish(sessionResult)
    }
}
