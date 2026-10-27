//
//  PCMockPermissionService.swift
//  PocketCoach
//

/// Mock camera permission service for tests and previews.
final class PCMockPermissionService: PCCameraPermissionServicing {
    /// Injected camera authorization status.
    var status: PCCameraPermissionStatus

    /// Result to return when requestPermission() is invoked.
    var requestPermissionResult: Bool = true

    /// Tracks whether requestPermission() has been called.
    var requestPermissionCalled = false

    /// Initializes mock permission service with specified initial status.
    init(status: PCCameraPermissionStatus = .authorized) {
        self.status = status
    }

    /// Simulates camera access request.
    func requestPermission() async -> Bool {
        requestPermissionCalled = true
        return requestPermissionResult
    }
}
