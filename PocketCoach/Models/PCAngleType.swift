//
//  PCAngleType.swift
//  PocketCoach
//

/// Anatomical angle and alignment classifications monitored during exercise form evaluation.
///
/// Note: `hipSag` represents a unitless signed line offset rather than an angle in degrees;
/// this type may be renamed to a more general measurement name in a future iteration.
enum PCAngleType: String, Codable, CaseIterable, Sendable {
    /// Angle formed at the knee joint between hip, knee, and ankle on the highest-confidence side.
    case knee

    /// Angle formed at the hip joint between shoulder, hip, and knee.
    case hip

    /// Angle formed at the elbow joint between shoulder, elbow, and wrist.
    case elbow

    /// Straightness of the body line across shoulder, hip, and ankle for horizontal exercises.
    case bodyLine

    /// Back lean of the torso from hip to shoulder relative to the vertical axis in upright exercises.
    case torsoLean

    /// Angle formed at the front leg's knee joint between hip, knee, and ankle during split-stance exercises.
    case frontKnee

    /// Angle formed at the rear leg's knee joint between hip, knee, and ankle during split-stance exercises.
    case rearKnee

    /// Signed normalized perpendicular offset of the hip from the shoulder-to-ankle line (positive = sag, negative = pike).
    case hipSag

    /// Lean of the upper arm from elbow to shoulder relative to the vertical axis (near zero when stacked).
    case upperArmLean

    /// Side-independent geometric definition specifying how this measurement is computed.
    var definition: PCAngleDefinition {
        switch self {
        case .knee, .frontKnee, .rearKnee:
            return .threePoint(.hip, .knee, .ankle)
        case .hip:
            return .threePoint(.shoulder, .hip, .knee)
        case .elbow:
            return .threePoint(.shoulder, .elbow, .wrist)
        case .bodyLine:
            return .threePoint(.shoulder, .hip, .ankle)
        case .torsoLean:
            return .fromVertical(.hip, .shoulder)
        case .hipSag:
            return .lineOffset(.shoulder, .hip, .ankle)
        case .upperArmLean:
            return .fromVertical(.elbow, .shoulder)
        }
    }

    /// Rule used by the form engine to resolve which body side to evaluate on each frame.
    var sideRule: PCSideRule {
        switch self {
        case .frontKnee:
            return .frontLeg
        case .rearKnee:
            return .rearLeg
        case .knee, .hip, .elbow, .bodyLine, .torsoLean, .hipSag, .upperArmLean:
            return .bestConfidence
        }
    }
}
