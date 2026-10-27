//
//  PCSkeletonOverlayView.swift
//  PocketCoach
//

/// High-performance joint highlight overlay rendered via Canvas without connecting lines.
struct PCSkeletonOverlayView: View {
    @Environment(\.pcConfiguration) private var config

    /// Normalized joint landmarks actively tracked for the current exercise.
    let jointStates: [PCJointState]

    /// Current tracking quality determining whether to show feedback or neutral tint.
    let trackingQuality: PCTrackingQuality

    var body: some View {
        Canvas { context, size in
            guard !jointStates.isEmpty else { return }

            let isTrackingGood = trackingQuality.isGood

            for joint in jointStates {
                let center = CGPoint(x: joint.x * size.width, y: joint.y * size.height)
                let color = nodeColor(for: joint.status, isTrackingGood: isTrackingGood)

                let haloRect = CGRect(
                    x: center.x - PCConstants.jointHaloRadius,
                    y: center.y - PCConstants.jointHaloRadius,
                    width: PCConstants.jointHaloRadius * 2.0,
                    height: PCConstants.jointHaloRadius * 2.0
                )
                context.fill(Path(ellipseIn: haloRect), with: .color(color.opacity(0.28)))

                let dotRect = CGRect(
                    x: center.x - PCConstants.jointRadius,
                    y: center.y - PCConstants.jointRadius,
                    width: PCConstants.jointRadius * 2.0,
                    height: PCConstants.jointRadius * 2.0
                )
                context.fill(Path(ellipseIn: dotRect), with: .color(color))
                context.stroke(
                    Path(ellipseIn: dotRect),
                    with: .color(.white),
                    lineWidth: 2.0
                )
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private func nodeColor(for status: PCJointFeedbackStatus, isTrackingGood: Bool) -> Color {
        guard isTrackingGood else { return config.neutralColor }

        switch status {
        case .good:
            return config.successColor
        case .warning, .error:
            return config.errorColor
        case .neutral:
            return config.neutralColor
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        PCSkeletonOverlayView(
            jointStates: [
                PCJointState(name: .leftShoulder, x: 0.48, y: 0.30, status: .good),
                PCJointState(name: .leftHip, x: 0.52, y: 0.54, status: .good),
                PCJointState(name: .leftKnee, x: 0.44, y: 0.72, status: .error),
                PCJointState(name: .leftAnkle, x: 0.50, y: 0.88, status: .good)
            ],
            trackingQuality: .good
        )
    }
}
