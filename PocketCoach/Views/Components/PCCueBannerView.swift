//
//  PCCueBannerView.swift
//  PocketCoach
//

/// Animated high-visibility banner presenting live form correction cues to the athlete with sharp 0px geometry.
struct PCCueBannerView: View {
    @Environment(\.pcConfiguration) private var config

    /// Current corrective coaching instruction.
    let cue: String?

    var body: some View {
        Group {
            if let cue = cue, !cue.isEmpty {
                HStack(spacing: 12) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundColor(config.warningColor)
                        .imageScale(.large)

                    Text(cue)
                        .font(config.cueFont)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    Rectangle()
                        .fill(Color.pcLamboCharcoal)
                        .overlay(
                            Rectangle()
                                .stroke(config.warningColor.opacity(0.8), lineWidth: 1.5)
                        )
                )
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.95).combined(with: .opacity),
                    removal: .opacity
                ))
                .accessibilityElement(children: .combine)
                .accessibilityLabel(String(format: NSLocalizedString("pc_cue_accessibility", tableName: "PocketCoach", bundle: .main, value: "Form correction: %@", comment: ""), cue))
            }
        }
        .animation(.easeInOut(duration: 0.25), value: cue)
    }
}

#Preview {
    ZStack {
        Color.pcLamboBlack.ignoresSafeArea()
        PCCueBannerView(cue: "Keep your chest lifted")
    }
}
