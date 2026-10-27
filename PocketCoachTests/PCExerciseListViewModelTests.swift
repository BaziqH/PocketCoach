//
//  PCExerciseListViewModelTests.swift
//  PocketCoachAppTests
//

import XCTest
@testable import PocketCoach

@MainActor
final class PCExerciseListViewModelTests: XCTestCase {
    func test_loadExercises_populatesFromStaticList() {
        // Given
        let viewModel = PCExerciseListViewModel()

        // When
        viewModel.loadExercises()

        // Then
        XCTAssertFalse(viewModel.exercises.isEmpty)
        XCTAssertEqual(viewModel.exercises.count, PCExercise.all.count)
        XCTAssertEqual(viewModel.exercises.first?.id, "squat")
    }

    func test_selectExercise_updatesState() {
        // Given
        let viewModel = PCExerciseListViewModel()
        let exercise = PCExercise(
            id: "squat",
            name: "Bodyweight Squats",
            systemImageName: "figure.strengthtraining.traditional",
            cameraView: .side,
            instructions: "Squat form instructions"
        )

        // When
        viewModel.select(exercise: exercise)

        // Then
        XCTAssertEqual(viewModel.selectedExercise, exercise)
    }
}
