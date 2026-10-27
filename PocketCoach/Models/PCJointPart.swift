//
//  PCJointPart.swift
//  PocketCoach
//

/// Side-independent anatomical joint part used in angle definitions.
enum PCJointPart: String, Codable, CaseIterable, Sendable {
    /// Shoulder joint part.
    case shoulder

    /// Elbow joint part.
    case elbow

    /// Wrist joint part.
    case wrist

    /// Hip joint part.
    case hip

    /// Knee joint part.
    case knee

    /// Ankle joint part.
    case ankle
}
