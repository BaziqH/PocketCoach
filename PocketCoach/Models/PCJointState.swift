//
//  PCJointState.swift
//  PocketCoach
//

/// Visual feedback classification for an individual joint landmark.
enum PCJointFeedbackStatus: String, Codable, Sendable {
    case good
    case warning
    case error
    case neutral
}

/// Instantaneous 2D normalized position and form status of an individual body joint.
struct PCJointState: Identifiable, Codable, Equatable, Sendable {
    var id: String { name.rawValue }

    /// Anatomical landmark identifier.
    let name: PCJointName

    /// Horizontal position normalized to 0.0 (left) through 1.0 (right).
    let x: Double

    /// Vertical position normalized to 0.0 (top) through 1.0 (bottom).
    let y: Double

    /// Form verification status determining visual highlighting.
    let status: PCJointFeedbackStatus
}
