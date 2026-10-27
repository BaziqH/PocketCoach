//
//  PCCameraPermissionStatus.swift
//  PocketCoach
//

/// Permission states for device camera capture.
enum PCCameraPermissionStatus: String, Codable, CaseIterable, Sendable {
    case authorized
    case denied
    case restricted
    case notDetermined
}
