//
//  PCCameraView.swift
//  PocketCoach
//

/// Required camera angle perspective relative to the user's body.
enum PCCameraView: String, Codable, CaseIterable, Sendable {
    /// Phone positioned parallel to the side of the user.
    case side = "Side view"

    /// Phone positioned directly facing the user.
    case front = "Front view"

    /// Phone positioned behind the user.
    case back = "Back view"
}
