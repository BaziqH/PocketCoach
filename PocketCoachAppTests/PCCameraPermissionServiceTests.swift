//
//  PCCameraPermissionServiceTests.swift
//  PocketCoachAppTests
//

import XCTest
@testable import PocketCoach

final class PCCameraPermissionServiceTests: XCTestCase {
    func test_permissionStatus_allCases_areUniqueAndSendable() {
        let statuses: [PCCameraPermissionStatus] = [.authorized, .denied, .restricted, .notDetermined]
        XCTAssertEqual(Set(statuses).count, 4)
    }

    func test_concretePermissionService_simulatorReturnsAuthorized() async {
        let service = PCCameraPermissionService()

        #if targetEnvironment(simulator)
        XCTAssertEqual(service.status, .authorized)
        let granted = await service.requestPermission()
        XCTAssertTrue(granted)
        #else
        // On physical devices without camera description, status safely defaults to .denied
        if Bundle.main.object(forInfoDictionaryKey: "NSCameraUsageDescription") == nil {
            XCTAssertEqual(service.status, .denied)
            let granted = await service.requestPermission()
            XCTAssertFalse(granted)
        }
        #endif
    }

    func test_mockPermissionService_tracksCallsAndReturnsConfiguredStatus() async {
        let mockService = PCMockPermissionService(status: .notDetermined)
        mockService.requestPermissionResult = true

        XCTAssertEqual(mockService.status, .notDetermined)
        XCTAssertFalse(mockService.requestPermissionCalled)

        let granted = await mockService.requestPermission()
        XCTAssertTrue(granted)
        XCTAssertTrue(mockService.requestPermissionCalled)
    }
}
