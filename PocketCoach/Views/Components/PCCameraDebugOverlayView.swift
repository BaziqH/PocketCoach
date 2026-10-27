//
//  PCCameraDebugOverlayView.swift
//  PocketCoach
//

#if DEBUG

/// Diagnostics overlay presenting real-time camera FPS, resolution, dropped frames, and position.
struct PCCameraDebugOverlayView: View {
    let metrics: PCCameraDebugMetrics

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 8) {
                Circle()
                    .fill(Color.green)
                    .frame(width: 6, height: 6)
                Text("CAMERA DEBUG")
                    .font(.system(size: 10, weight: .black, design: .monospaced))
                    .foregroundColor(.white)
            }

            Text(String(format: "FPS: %.1f", metrics.fps))
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundColor(.white)

            Text("Res: \(metrics.frameWidth)x\(metrics.frameHeight)")
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .foregroundColor(Color.white.opacity(0.8))

            Text("Lens: \(metrics.position.rawValue.uppercased())")
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .foregroundColor(Color.white.opacity(0.8))

            Text("Dropped: \(metrics.droppedFrames)")
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .foregroundColor(metrics.droppedFrames > 0 ? .orange : Color.white.opacity(0.8))
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color.black.opacity(0.75))
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        PCCameraDebugOverlayView(
            metrics: PCCameraDebugMetrics(
                fps: 29.8,
                droppedFrames: 0,
                frameWidth: 1280,
                frameHeight: 720,
                position: .front
            )
        )
    }
}

#endif
