//
//  PCConstants.swift
//  PocketCoach
//

@_exported import SwiftUI
@_exported import UIKit
@_exported import AVFoundation
@_exported import CoreMedia
@_exported import CoreVideo
@_exported import Combine

/// Project-wide constants for the Pocket Coach feature.
@MainActor
enum PCConstants {
    /// Minimum time in seconds that a form cue banner must remain on screen before transitioning.
    static let minCueDisplayDuration: TimeInterval = 2.0

    /// Duration in seconds of continuous good tracking required to automatically dismiss the positioning guide.
    static let positioningGuideDismissDelay: TimeInterval = 3.5

    /// Radius in points for the outer highlight halo around a tracked joint indicator.
    static let jointHaloRadius: CGFloat = 14.0

    /// Radius in points for tracked joint indicators.
    static let jointRadius: CGFloat = 8.0
}
