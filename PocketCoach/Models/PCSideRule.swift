//
//  PCSideRule.swift
//  PocketCoach
//

/// Rule determining which anatomical body side the form engine evaluates for an angle on each frame.
enum PCSideRule: String, Codable, CaseIterable, Sendable {
    /// Selects the side whose involved joints have higher detection confidence (typically the side closer to the camera).
    case bestConfidence

    /// Selects the leg whose ankle is further forward in the direction the athlete is facing.
    case frontLeg

    /// Selects the leg opposite to the front leg.
    case rearLeg
}
