//
//  PCFormEngine.swift
//  PocketCoach
//

/// Contract for pose estimation, rep counting, and real-time form correction services.
protocol PCFormEngine: AnyObject {
    /// Commences pose tracking and streaming form updates.
    func start() async throws

    /// Concludes tracking and compiles the aggregate session result.
    func stop() async -> PCSessionResult

    /// Continuous stream of frame-by-frame pose updates and coaching cues.
    var updates: AsyncStream<PCFormUpdate> { get }
}
