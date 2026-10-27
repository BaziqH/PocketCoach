//
//  PCBodySide.swift
//  PocketCoach
//

/// Anatomical side of the body used to resolve side-specific joint landmarks.
enum PCBodySide: String, Codable, CaseIterable, Sendable {
    /// Left anatomical side.
    case left

    /// Right anatomical side.
    case right
}
