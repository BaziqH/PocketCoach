//
//  PCCameraPermissionServicing.swift
//  PocketCoach
//

/// Service protocol for querying and requesting camera authorization.
protocol PCCameraPermissionServicing: AnyObject {
    /// Current camera authorization status.
    var status: PCCameraPermissionStatus { get }

    /// Requests camera authorization from the user if not yet determined.
    func requestPermission() async -> Bool
}
