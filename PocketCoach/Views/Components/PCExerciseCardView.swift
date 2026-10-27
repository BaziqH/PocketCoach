//
//  PCExerciseCardView.swift
//  PocketCoach
//

/// Visual card component displaying an exercise's iconography, metadata tags, and guidance
/// in a clean, high-end consumer fitness aesthetic.
struct PCExerciseCardView: View {
    @Environment(\.pcConfiguration) private var config

    /// The exercise presented on this card.
    let exercise: PCExercise

    var body: some View {
        HStack(spacing: 14) {
            // Hexagonal Insignia Badge
            ZStack {
                PCHexagonShape()
                    .stroke(Color.pcLamboGold.opacity(0.8), lineWidth: 1.2)
                    .frame(width: 50, height: 46)

                PCHexagonShape()
                    .fill(Color.pcLamboDarkIron)
                    .frame(width: 44, height: 40)

                Image(systemName: exercise.systemImageName)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color.pcLamboGold)
            }

            // Exercise Title, Badges, and Instruction Snippet
            VStack(alignment: .leading, spacing: 5) {
                Text(exercise.name)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(1)

                // Clean Consumer Metadata Badges
                HStack(spacing: 6) {
                    // Perspective Tag
                    HStack(spacing: 4) {
                        Image(systemName: "video.fill")
                            .font(.system(size: 9))
                        Text(exercise.cameraView.rawValue.capitalized)
                            .font(.system(size: 11, weight: .medium))
                    }
                    .foregroundColor(Color.pcLamboAsh)
                    .padding(.vertical, 3)
                    .padding(.horizontal, 7)
                    .background(Color.pcLamboDarkIron)

                    // Tracking Mode Tag
                    HStack(spacing: 4) {
                        Image(systemName: exercise.trackingMode == .reps ? "repeat" : "timer")
                            .font(.system(size: 9))
                        Text(trackingModeLabel)
                            .font(.system(size: 11, weight: .medium))
                    }
                    .foregroundColor(Color.pcLamboGoldText)
                    .padding(.vertical, 3)
                    .padding(.horizontal, 7)
                    .background(Color.pcLamboDarkIron)
                }

                // Instruction preview snippet
                Text(exercise.instructions)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(Color.pcLamboAsh)
                    .lineLimit(2)
                    .lineSpacing(2)
                    .multilineTextAlignment(.leading)
            }

            Spacer(minLength: 4)

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Color.pcLamboAsh)
                .padding(.trailing, 4)
        }
        .padding(14)
        .background(Color.pcLamboCharcoal)
        .border(Color.pcLamboDarkIron, width: 1)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(combinedAccessibilityLabel)
    }

    private var trackingModeLabel: String {
        switch exercise.trackingMode {
        case .reps:
            return NSLocalizedString("pc_mode_reps", tableName: "PocketCoach", bundle: .main, value: "Reps", comment: "")
        case .hold:
            return NSLocalizedString("pc_mode_hold", tableName: "PocketCoach", bundle: .main, value: "Hold", comment: "")
        }
    }

    private var combinedAccessibilityLabel: String {
        "\(exercise.name), \(exercise.cameraView.rawValue), \(trackingModeLabel)"
    }
}

#Preview {
    ZStack {
        Color.pcLamboBlack.ignoresSafeArea()
        PCExerciseCardView(exercise: PCExercise.all[0])
            .padding()
    }
}
