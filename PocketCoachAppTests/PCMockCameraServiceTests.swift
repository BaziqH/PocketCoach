//
//  PCMockCameraServiceTests.swift
//  PocketCoachAppTests
//

import XCTest
@testable import PocketCoach

final class PCMockCameraServiceTests: XCTestCase {
    func test_frameStream_deliversFrames_andFinishesOnStop() async throws {
        let mockCamera = PCMockCameraService()
        try await mockCamera.start()

        var receivedFrames: [PCCameraFrame] = []
        let consumerTask = Task {
            for await frame in mockCamera.frames {
                receivedFrames.append(frame)
                if receivedFrames.count >= 2 {
                    break
                }
            }
        }

        // Wait for frames to be produced
        try await Task.sleep(nanoseconds: 120_000_000)
        await consumerTask.value

        XCTAssertGreaterThanOrEqual(receivedFrames.count, 1)
        if let first = receivedFrames.first {
            XCTAssertTrue(first.isMirrored) // Front camera default is mirrored
            XCTAssertGreaterThan(first.timestamp, 0)
        }

        // Calling stop() must terminate the stream
        await mockCamera.stop()

        var streamDidFinish = false
        let finishCheckTask = Task {
            for await _ in mockCamera.frames {
                // If stream is finished, loop terminates immediately
            }
            streamDidFinish = true
        }

        try await Task.sleep(nanoseconds: 50_000_000)
        await finishCheckTask.value
        XCTAssertTrue(streamDidFinish)
    }

    func test_switchCamera_togglesPosition() async throws {
        let mockCamera = PCMockCameraService()
        XCTAssertEqual(mockCamera.position, .front)

        try await mockCamera.switchCamera()
        XCTAssertEqual(mockCamera.position, .back)

        try await mockCamera.switchCamera()
        XCTAssertEqual(mockCamera.position, .front)
    }

    func test_startThrows_whenErrorIsInjected() async {
        let mockCamera = PCMockCameraService()
        mockCamera.throwErrorOnStart = .noCameraAvailable

        do {
            try await mockCamera.start()
            XCTFail("Expected mock camera to throw noCameraAvailable")
        } catch let error as PCCameraError {
            XCTAssertEqual(error, .noCameraAvailable)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func test_interruptionTrigger_firesCallback() async {
        let mockCamera = PCMockCameraService()
        var reportedInterruption: Bool?

        mockCamera.onInterruptionChanged = { isInterrupted in
            reportedInterruption = isInterrupted
        }

        mockCamera.triggerInterruption(true)
        XCTAssertEqual(reportedInterruption, true)

        mockCamera.triggerInterruption(false)
        XCTAssertEqual(reportedInterruption, false)
    }
}
