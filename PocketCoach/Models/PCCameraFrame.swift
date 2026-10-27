//
//  PCCameraFrame.swift
//  PocketCoach
//

/// An immutable video frame container delivered from the camera hardware pipeline.
///
/// Conformance to `@unchecked Sendable` is thread-safe because the underlying `CVPixelBuffer`
/// reference is treated as strictly read-only after capture delivery and is never modified concurrently.
struct PCCameraFrame: @unchecked Sendable {
    /// Hardware pixel buffer holding frame image data.
    let pixelBuffer: CVPixelBuffer

    /// Presentation timestamp in seconds.
    let timestamp: TimeInterval

    /// Flag indicating whether the frame originated from a front-facing camera.
    let isMirrored: Bool

    /// Initializes a camera frame container.
    init(pixelBuffer: CVPixelBuffer, timestamp: TimeInterval, isMirrored: Bool) {
        self.pixelBuffer = pixelBuffer
        self.timestamp = timestamp
        self.isMirrored = isMirrored
    }
}
