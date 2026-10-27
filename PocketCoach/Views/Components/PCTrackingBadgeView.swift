//
//  PCTrackingBadgeView.swift
//  PocketCoach
//

/// Visual badge communicating camera visibility and tracking confidence with sharp 0px geometry.
struct PCTrackingBadgeView: View {
    @Environment(\.pcConfiguration) private var config

    /// Current tracking state.
    let quality: PCTrackingQuality

    private var dotColor: Color {
        switch quality {
        case .good:
            return config.successColor
        case .moveBack, .bodyNotFullyVisible:
            return config.warningColor
        case .poor:
            return config.errorColor
        }
    }

    var body: some View {
        HStack(spacing: 8) {
            Rectangle()
                .fill(dotColor)
                .frame(width: 6, height: 6)

            Text(quality.localizedDescription)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .background(
            Rectangle()
                .fill(Color.pcLamboDarkIron)
                .overlay(
                    Rectangle()
                        .stroke(dotColor.opacity(0.4), lineWidth: 1)
                )
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(String(format: NSLocalizedString("pc_tracking_quality_accessibility", tableName: "PocketCoach", bundle: .main, value: "Tracking quality: %@", comment: ""), quality.localizedDescription))
    }
}

#Preview {
    ZStack {
        Color.pcLamboBlack.ignoresSafeArea()
        VStack(spacing: 12) {
            PCTrackingBadgeView(quality: .good)
            PCTrackingBadgeView(quality: .moveBack)
            PCTrackingBadgeView(quality: .bodyNotFullyVisible)
            PCTrackingBadgeView(quality: .poor(reason: "Low lighting"))
        }
    }
}
