//
//  PCCameraService.swift
//  PocketCoach
//

/// Protocol governing camera capture session lifecycle, frame delivery, and preview attachment.
protocol PCCameraService: AnyObject {
    /// Continuous stream yielding the newest available camera frames.
    var frames: AsyncStream<PCCameraFrame> { get }

    /// Active camera lens position (front or back).
    var position: PCCameraPosition { get }

    /// Commences camera capture on a background queue.
    func start() async throws

    /// Concludes camera capture and finishes the frame stream.
    func stop() async

    /// Toggles between front and rear cameras.
    func switchCamera() async throws

    /// Underlying capture session for preview layer binding (nil in mock environments).
    var captureSession: AVCaptureSession? { get }
}
