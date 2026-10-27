//
//  PCMockCameraService.swift
//  PocketCoach
//

/// Mock camera service generating synthetic frames and simulating camera operations for tests and simulator.
final class PCMockCameraService: PCCameraService {
    private var currentPosition: PCCameraPosition = .front
    private var frameContinuation: AsyncStream<PCCameraFrame>.Continuation?
    private var currentStream: AsyncStream<PCCameraFrame>?
    private var generationTask: Task<Void, Never>?
    private var isRunning = false

    /// Optional error injected to test failed start conditions.
    var throwErrorOnStart: PCCameraError?

    /// Callback invoked when interruption state transitions.
    var onInterruptionChanged: ((Bool) -> Void)?

    /// Callback invoked when errors occur.
    var onError: ((PCCameraError) -> Void)?

    /// Always nil in mock environments because no hardware session exists.
    var captureSession: AVCaptureSession? {
        nil
    }

    /// Current mock camera position.
    var position: PCCameraPosition {
        currentPosition
    }

    /// Continuous stream emitting mock frames.
    var frames: AsyncStream<PCCameraFrame> {
        if let existing = currentStream {
            return existing
        }
        let stream = AsyncStream(PCCameraFrame.self, bufferingPolicy: .bufferingNewest(1)) { [weak self] continuation in
            self?.frameContinuation = continuation
        }
        self.currentStream = stream
        return stream
    }

    /// Starts mock frame generation.
    func start() async throws {
        if let error = throwErrorOnStart {
            throw error
        }

        // Prepare stream if not yet active
        _ = frames
        isRunning = true
        startMockFrameGeneration()
    }

    /// Halts mock frame generation and terminates the stream.
    func stop() async {
        isRunning = false
        generationTask?.cancel()
        generationTask = nil
        frameContinuation?.finish()
        frameContinuation = nil
        currentStream = nil
    }

    /// Toggles mock camera position.
    func switchCamera() async throws {
        currentPosition = (currentPosition == .front) ? .back : .front
    }

    /// Simulates hardware session interruption for testing.
    func triggerInterruption(_ isInterrupted: Bool) {
        onInterruptionChanged?(isInterrupted)
    }

    private func startMockFrameGeneration() {
        generationTask?.cancel()
        generationTask = Task { [weak self] in
            guard let self = self else { return }

            let sampleBuffer = self.createMockPixelBuffer()
            while !Task.isCancelled && self.isRunning {
                if let buffer = sampleBuffer {
                    let now = Date().timeIntervalSince1970
                    let isMirrored = (self.currentPosition == .front)
                    let frame = PCCameraFrame(pixelBuffer: buffer, timestamp: now, isMirrored: isMirrored)
                    self.frameContinuation?.yield(frame)
                }

                // ~30 fps interval (33ms)
                try? await Task.sleep(nanoseconds: 33_333_333)
            }
        }
    }

    private func createMockPixelBuffer(width: Int = 1280, height: Int = 720) -> CVPixelBuffer? {
        var pixelBuffer: CVPixelBuffer?
        let attrs: [CFString: Any] = [
            kCVPixelBufferCGImageCompatibilityKey: false,
            kCVPixelBufferCGBitmapContextCompatibilityKey: false
        ]
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            width,
            height,
            kCVPixelFormatType_32BGRA,
            attrs as CFDictionary,
            &pixelBuffer
        )
        guard status == kCVReturnSuccess else { return nil }
        return pixelBuffer
    }
}
