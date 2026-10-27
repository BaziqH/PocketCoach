//
//  PCCameraPosition.swift
//  PocketCoach
//

/// Physical camera hardware lens position on the device.
enum PCCameraPosition: String, Codable, CaseIterable, Sendable {
    /// Front-facing (selfie) camera facing the user.
    case front

    /// Rear-facing primary camera facing away from the screen.
    case back
}
