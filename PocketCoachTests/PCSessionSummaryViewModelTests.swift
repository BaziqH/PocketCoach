//
//  PCSessionSummaryViewModelTests.swift
//  PocketCoachAppTests
//

import XCTest
@testable import PocketCoach

@MainActor
final class PCSessionSummaryViewModelTests: XCTestCase {
    private var testExercise: PCExercise!

    override func setUp() {
        super.setUp()
        testExercise = PCExercise(
            id: "squat",
            name: "Bodyweight Squats",
            systemImageName: "figure.strengthtraining.traditional",
            cameraView: .side,
            instructions: "Squat form instructions"
        )
    }

    func test_summaryMetrics_withErrors() {
        let result = PCSessionResult(
            exercise: testExercise,
            completedReps: 15,
            repsWithErrors: 4,
            mostCommonError: "Knees inward",
            duration: 95.0
        )

        let viewModel = PCSessionSummaryViewModel(result: result, canChangeExercise: true)

        XCTAssertEqual(viewModel.exerciseName, "Bodyweight Squats")
        XCTAssertEqual(viewModel.totalRepsText, "15")
        XCTAssertEqual(viewModel.cleanRepsText, "11")
        XCTAssertEqual(viewModel.formErrorsText, "4")
        XCTAssertEqual(viewModel.mostCommonErrorText, "Knees inward")
        XCTAssertEqual(viewModel.formattedDuration, "01:35")
        XCTAssertTrue(viewModel.canChangeExercise)
    }

    func test_summaryMetrics_withoutErrors() {
        let result = PCSessionResult(
            exercise: testExercise,
            completedReps: 10,
            repsWithErrors: 0,
            mostCommonError: nil,
            duration: 62.0
        )

        let viewModel = PCSessionSummaryViewModel(result: result, canChangeExercise: false)

        XCTAssertEqual(viewModel.cleanRepsText, "10")
        XCTAssertEqual(viewModel.formErrorsText, "0")
        XCTAssertEqual(viewModel.mostCommonErrorText, "No errors detected! Great form!")
        XCTAssertEqual(viewModel.formattedDuration, "01:02")
        XCTAssertFalse(viewModel.canChangeExercise)
    }
}
