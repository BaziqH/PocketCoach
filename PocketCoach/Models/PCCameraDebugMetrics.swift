//
//  PCCameraDebugMetrics.swift
//  PocketCoach
//

#if DEBUG

/// Lightweight snapshot of live camera pipeline diagnostic metrics.
struct PCCameraDebugMetrics: Equatable, Sendable {
    var fps: Double = 0.0
    var droppedFrames: Int = 0
    var frameWidth: Int = 0
    var frameHeight: Int = 0
    var position: PCCameraPosition = .front
}

#endif
