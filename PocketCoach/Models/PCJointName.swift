//
//  PCJointName.swift
//  PocketCoach
//

/// Standard anatomical body pose landmarks matching Vision framework body joints one-to-one.
enum PCJointName: String, Codable, CaseIterable, Sendable {
    case nose
    case neck
    case root
    case leftEar
    case rightEar
    case leftShoulder
    case rightShoulder
    case leftElbow
    case rightElbow
    case leftWrist
    case rightWrist
    case leftHip
    case rightHip
    case leftKnee
    case rightKnee
    case leftAnkle
    case rightAnkle

    /// Resolves a side-independent joint part and body side into its specific joint landmark.
    static func joint(_ part: PCJointPart, _ side: PCBodySide) -> PCJointName {
        switch (part, side) {
        case (.shoulder, .left):
            return .leftShoulder
        case (.shoulder, .right):
            return .rightShoulder
        case (.elbow, .left):
            return .leftElbow
        case (.elbow, .right):
            return .rightElbow
        case (.wrist, .left):
            return .leftWrist
        case (.wrist, .right):
            return .rightWrist
        case (.hip, .left):
            return .leftHip
        case (.hip, .right):
            return .rightHip
        case (.knee, .left):
            return .leftKnee
        case (.knee, .right):
            return .rightKnee
        case (.ankle, .left):
            return .leftAnkle
        case (.ankle, .right):
            return .rightAnkle
        }
    }
}
