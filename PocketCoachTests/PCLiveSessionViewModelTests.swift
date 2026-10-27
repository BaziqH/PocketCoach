//
//  PCLiveSessionViewModelTests.swift
//  PocketCoachAppTests
//

import XCTest
@testable import PocketCoach

@MainActor
final class PCLiveSessionViewModelTests: XCTestCase {
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

    func test_onAppear_withAuthorizedPermission_startsCameraAndTransitionsToRunning() async {
        let mockEngine = PCMockFormEngine(exercise: testExercise, cannedUpdates: [])
        let mockCamera = PCMockCameraService()
        let mockPermission = PCMockPermissionService(status: .authorized)

        let viewModel = PCLiveSessionViewModel(
            exercise: testExercise,
            engine: mockEngine,
            cameraService: mockCamera,
            permissionService: mockPermission
        )

        XCTAssertEqual(viewModel.cameraState, .idle)

        await viewModel.onAppear()

        XCTAssertEqual(viewModel.cameraPermissionStatus, .authorized)
        XCTAssertEqual(viewModel.cameraState, .running)
        XCTAssertFalse(mockPermission.requestPermissionCalled)
    }

    func test_onAppear_withNotDeterminedPermission_requestsPermission() async {
        let mockEngine = PCMockFormEngine(exercise: testExercise, cannedUpdates: [])
        let mockCamera = PCMockCameraService()
        let mockPermission = PCMockPermissionService(status: .notDetermined)
        mockPermission.requestPermissionResult = true

        let viewModel = PCLiveSessionViewModel(
            exercise: testExercise,
            engine: mockEngine,
            cameraService: mockCamera,
            permissionService: mockPermission
        )

        await viewModel.onAppear()

        XCTAssertTrue(mockPermission.requestPermissionCalled)
        XCTAssertEqual(viewModel.cameraPermissionStatus, .authorized)
        XCTAssertEqual(viewModel.cameraState, .running)
    }

    func test_onAppear_withDeniedPermission_transitionsToFailedPermissionDenied() async {
        let mockEngine = PCMockFormEngine(exercise: testExercise, cannedUpdates: [])
        let mockCamera = PCMockCameraService()
        let mockPermission = PCMockPermissionService(status: .denied)

        let viewModel = PCLiveSessionViewModel(
            exercise: testExercise,
            engine: mockEngine,
            cameraService: mockCamera,
            permissionService: mockPermission
        )

        await viewModel.onAppear()

        XCTAssertEqual(viewModel.cameraPermissionStatus, .denied)
        XCTAssertEqual(viewModel.cameraState, .failed(.permissionDenied))
    }

    func test_onAppear_withCameraStartFailure_transitionsToFailedState() async {
        let mockEngine = PCMockFormEngine(exercise: testExercise, cannedUpdates: [])
        let mockCamera = PCMockCameraService()
        mockCamera.throwErrorOnStart = .configurationFailed
        let mockPermission = PCMockPermissionService(status: .authorized)

        let viewModel = PCLiveSessionViewModel(
            exercise: testExercise,
            engine: mockEngine,
            cameraService: mockCamera,
            permissionService: mockPermission
        )

        await viewModel.onAppear()

        XCTAssertEqual(viewModel.cameraState, .failed(.configurationFailed))
    }

    func test_cameraInterruption_transitionsToInterrupted_andResumesToRunning() async {
        let mockEngine = PCMockFormEngine(exercise: testExercise, cannedUpdates: [])
        let mockCamera = PCMockCameraService()
        let mockPermission = PCMockPermissionService(status: .authorized)

        let viewModel = PCLiveSessionViewModel(
            exercise: testExercise,
            engine: mockEngine,
            cameraService: mockCamera,
            permissionService: mockPermission
        )

        await viewModel.onAppear()
        XCTAssertEqual(viewModel.cameraState, .running)

        mockCamera.triggerInterruption(true)
        XCTAssertEqual(viewModel.cameraState, .interrupted)

        mockCamera.triggerInterruption(false)
        XCTAssertEqual(viewModel.cameraState, .running)
    }

    func test_flipCamera_switchesCameraPosition() async {
        let mockEngine = PCMockFormEngine(exercise: testExercise, cannedUpdates: [])
        let mockCamera = PCMockCameraService()
        let mockPermission = PCMockPermissionService(status: .authorized)

        let viewModel = PCLiveSessionViewModel(
            exercise: testExercise,
            engine: mockEngine,
            cameraService: mockCamera,
            permissionService: mockPermission
        )

        await viewModel.onAppear()
        XCTAssertEqual(viewModel.cameraService.position, .front)

        await viewModel.flipCamera()
        XCTAssertEqual(viewModel.cameraService.position, .back)

        await viewModel.flipCamera()
        XCTAssertEqual(viewModel.cameraService.position, .front)
    }

    func test_formUpdates_processRepsAndJointStates() async {
        let update1 = PCFormUpdate(
            repCount: 5,
            trackingQuality: .good,
            jointStates: [
                PCJointState(name: .leftKnee, x: 0.45, y: 0.70, status: .good)
            ],
            currentCue: "Keep chest lifted"
        )

        let mockEngine = PCMockFormEngine(exercise: testExercise, cannedUpdates: [update1])
        let mockCamera = PCMockCameraService()
        let mockPermission = PCMockPermissionService(status: .authorized)

        let viewModel = PCLiveSessionViewModel(
            exercise: testExercise,
            engine: mockEngine,
            cameraService: mockCamera,
            permissionService: mockPermission,
            minimumCueDuration: 0.05,
            positioningDismissDelay: 0.05
        )

        await viewModel.onAppear()

        // Allow async stream processing
        try? await Task.sleep(nanoseconds: 50_000_000)

        XCTAssertEqual(viewModel.repCount, 5)
        XCTAssertEqual(viewModel.trackingQuality, .good)
        XCTAssertEqual(viewModel.jointStates.first?.status, .good)
        XCTAssertEqual(viewModel.currentCue, "Keep chest lifted")
    }

    func test_formUpdates_withPoorTracking_neutralizesJoints() async {
        let poorUpdate = PCFormUpdate(
            repCount: 2,
            trackingQuality: .poor(reason: "Too far"),
            jointStates: [
                PCJointState(name: .leftKnee, x: 0.45, y: 0.70, status: .error)
            ],
            currentCue: nil
        )

        let mockEngine = PCMockFormEngine(exercise: testExercise, cannedUpdates: [poorUpdate])
        let mockCamera = PCMockCameraService()
        let mockPermission = PCMockPermissionService(status: .authorized)

        let viewModel = PCLiveSessionViewModel(
            exercise: testExercise,
            engine: mockEngine,
            cameraService: mockCamera,
            permissionService: mockPermission
        )

        await viewModel.onAppear()
        try? await Task.sleep(nanoseconds: 50_000_000)

        XCTAssertEqual(viewModel.trackingQuality, .poor(reason: "Too far"))
        XCTAssertEqual(viewModel.jointStates.first?.status, .neutral)
    }

    func test_positioningGuide_autoDismisses_afterGoodTrackingDelay() async {
        let goodUpdate = PCFormUpdate(
            repCount: 0,
            trackingQuality: .good,
            jointStates: [],
            currentCue: nil
        )

        let mockEngine = PCMockFormEngine(exercise: testExercise, cannedUpdates: [goodUpdate])
        let mockCamera = PCMockCameraService()
        let mockPermission = PCMockPermissionService(status: .authorized)

        let viewModel = PCLiveSessionViewModel(
            exercise: testExercise,
            engine: mockEngine,
            cameraService: mockCamera,
            permissionService: mockPermission,
            positioningDismissDelay: 0.02
        )

        await viewModel.onAppear()
        XCTAssertTrue(viewModel.isPositioningGuideVisible)

        // Wait for delay to expire
        try? await Task.sleep(nanoseconds: 50_000_000)

        XCTAssertFalse(viewModel.isPositioningGuideVisible)
    }

    func test_finishSession_returnsResult_andResetsCameraState() async {
        let expectedResult = PCSessionResult(
            exercise: testExercise,
            completedReps: 10,
            repsWithErrors: 2,
            mostCommonError: "Knees inward",
            duration: 60.0
        )

        let mockEngine = PCMockFormEngine(exercise: testExercise, cannedUpdates: [], cannedResult: expectedResult)
        let mockCamera = PCMockCameraService()
        let mockPermission = PCMockPermissionService(status: .authorized)

        let viewModel = PCLiveSessionViewModel(
            exercise: testExercise,
            engine: mockEngine,
            cameraService: mockCamera,
            permissionService: mockPermission
        )

        await viewModel.onAppear()
        XCTAssertEqual(viewModel.cameraState, .running)

        let result = await viewModel.finishSession()

        XCTAssertEqual(result.completedReps, 10)
        XCTAssertEqual(result.repsWithErrors, 2)
        XCTAssertEqual(result.mostCommonError, "Knees inward")
        XCTAssertEqual(viewModel.cameraState, .idle)
    }
}
