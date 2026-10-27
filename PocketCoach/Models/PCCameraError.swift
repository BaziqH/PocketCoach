//
//  PCCameraError.swift
//  PocketCoach
//

/// Specific failure conditions arising during camera capture setup or execution.
enum PCCameraError: LocalizedError, Equatable, Sendable {
    /// Camera authorization was denied or restricted.
    case permissionDenied

    /// No appropriate video capture device could be found.
    case noCameraAvailable

    /// Device inputs or outputs could not be attached to the capture session.
    case configurationFailed

    /// Active session was interrupted by higher-priority hardware demands or backgrounding.
    case interrupted

    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return NSLocalizedString("pc_camera_access_needed_message", tableName: "PocketCoach", bundle: .main, value: "Camera access was denied.", comment: "")
        case .noCameraAvailable:
            return "No camera device is available on this system."
        case .configurationFailed:
            return "Failed to configure camera capture session."
        case .interrupted:
            return "Camera capture was interrupted by another process."
        }
    }
}
