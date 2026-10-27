//
//  PCCameraState.swift
//  PocketCoach
//

/// Real-time operational lifecycle status of the camera capture pipeline.
enum PCCameraState: Equatable, Sendable {
    /// Camera hardware is inactive and not running.
    case idle

    /// Camera capture session is initiating hardware configuration.
    case starting

    /// Hardware is capturing and actively streaming video frames.
    case running

    /// Capture has been suspended due to an incoming interruption (e.g. phone call).
    case interrupted

    /// Hardware initialization or runtime error occurred.
    case failed(PCCameraError)
}
