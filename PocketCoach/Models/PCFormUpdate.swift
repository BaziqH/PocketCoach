//
//  PCFormUpdate.swift
//  PocketCoach
//

/// Immutable frame update emitted by the form checking engine.
struct PCFormUpdate: Equatable, Sendable {
    /// Total completed repetitions detected up to this frame.
    let repCount: Int

    /// Current camera frame tracking fidelity.
    let trackingQuality: PCTrackingQuality

    /// Collection of normalized joint landmark positions.
    let jointStates: [PCJointState]

    /// Active coaching cue advice to be rendered on screen, if any.
    let currentCue: String?
}
