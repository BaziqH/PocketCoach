//
//  PCExerciseListViewModel.swift
//  PocketCoach
//

/// Presentation view model managing exercise selection catalog and state.
@MainActor
final class PCExerciseListViewModel: ObservableObject {
    /// Available exercises loaded from the static exercise catalog.
    @Published private(set) var exercises: [PCExercise] = []

    /// Currently active or highlighted exercise selection.
    @Published var selectedExercise: PCExercise?

    /// Human-readable error message if exercise loading fails.
    @Published private(set) var errorMessage: String?

    /// Indicates whether loading operations are underway.
    @Published private(set) var isLoading: Bool = false

    private let exerciseProvider: @MainActor () -> [PCExercise]

    /// Initializes the view model with the default static exercise catalog.
    @MainActor
    convenience init() {
        self.init(exerciseProvider: { PCExercise.all })
    }

    /// Initializes the view model with a custom exercise provider for testing.
    @MainActor
    init(exerciseProvider: @escaping @MainActor () -> [PCExercise]) {
        self.exerciseProvider = exerciseProvider
    }

    /// Loads exercises from the static PCExercise catalog.
    @MainActor
    func loadExercises() {
        isLoading = true
        errorMessage = nil
        self.exercises = exerciseProvider()
        self.isLoading = false
    }

    /// Selects an exercise to transition into a live coaching session.
    @MainActor
    func select(exercise: PCExercise) {
        self.selectedExercise = exercise
    }
}
