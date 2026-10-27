//
//  PCTrackingQuality.swift
//  PocketCoach
//

/// Real-time assessment of user visibility and pose estimation reliability.
enum PCTrackingQuality: Equatable, Sendable {
    /// Full body is clearly visible in the camera frame with high confidence.
    case good

    /// User is standing too close to the camera for complete skeletal tracking.
    case moveBack

    /// One or more required extremities are outside the viewport bounds.
    case bodyNotFullyVisible

    /// Tracking is degraded due to occlusion, poor lighting, or improper angle.
    case poor(reason: String)

    /// User-facing descriptive badge text.
    var localizedDescription: String {
        switch self {
        case .good:
            return NSLocalizedString("pc_tracking_good", tableName: "PocketCoach", bundle: .main, value: "Tracking good", comment: "")
        case .moveBack:
            return NSLocalizedString("pc_tracking_move_back", tableName: "PocketCoach", bundle: .main, value: "Move back", comment: "")
        case .bodyNotFullyVisible:
            return NSLocalizedString("pc_tracking_body_not_visible", tableName: "PocketCoach", bundle: .main, value: "Body not fully visible", comment: "")
        case .poor(let reason):
            return reason
        }
    }

    /// Convenience flag indicating whether tracking confidence is sufficient for active coaching.
    var isGood: Bool {
        if case .good = self { return true }
        return false
    }
}
