//
//  PCRepCounterView.swift
//  PocketCoach
//

/// Prominent, high-contrast numeric repetition counter styled with sharp 0px geometry.
struct PCRepCounterView: View {
    @Environment(\.pcConfiguration) private var config

    /// Current count of completed repetitions.
    let count: Int

    var body: some View {
        VStack(spacing: 2) {
            Text("\(count)")
                .font(config.counterFont)
                .foregroundColor(.white)
                .contentTransition(.identity)

            Text(NSLocalizedString("pc_summary_total_reps", tableName: "PocketCoach", bundle: .main, value: "Total Reps", comment: "").uppercased())
                .font(.system(size: 11, weight: .bold))
                .tracking(1.4)
                .foregroundColor(Color.pcLamboAsh)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 10)
        .background(
            Rectangle()
                .fill(Color.pcLamboDarkIron)
                .overlay(
                    Rectangle()
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(String(format: NSLocalizedString("pc_rep_counter_accessibility", tableName: "PocketCoach", bundle: .main, value: "Completed repetitions: %d", comment: ""), count))
    }
}

#Preview {
    ZStack {
        Color.pcLamboBlack.ignoresSafeArea()
        PCRepCounterView(count: 14)
    }
}
