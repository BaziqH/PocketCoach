//
//  PCPositioningGuideView.swift
//  PocketCoach
//

/// Translucent silhouette overlay prompting the user to place the phone in the preferred view before starting,
/// styled with the Lamborghini Design System's sharp 0px geometry and gold accents.
struct PCPositioningGuideView: View {
    @Environment(\.pcConfiguration) private var config

    /// Exercise being prepared for, providing preferred camera view and setup instructions.
    let exercise: PCExercise

    /// Action invoked when user taps to dismiss the guidance early.
    let onDismiss: () -> Void

    var body: some View {
        Button(action: onDismiss) {
            ZStack {
                Color.black.opacity(0.50)
                    .ignoresSafeArea()

                VStack(spacing: 20) {
                    Spacer()

                    // Preferred camera perspective badge (Sharp 0px tag)
                    HStack(spacing: 8) {
                        Image(systemName: "iphone.gen3")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color.pcLamboGold)

                        Text(exercise.cameraView.rawValue.capitalized)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Color.pcLamboDarkIron)
                    .border(Color.pcLamboGold.opacity(0.6), width: 1)

                    // Exercise posture silhouette outline (Sharp 0px frame)
                    Image(systemName: exercise.systemImageName)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 160, maxHeight: 220)
                        .foregroundColor(Color.white.opacity(0.85))
                        .padding(24)
                        .overlay(
                            Rectangle()
                                .strokeBorder(
                                    Color.white.opacity(0.5),
                                    style: StrokeStyle(lineWidth: 1.5, dash: [8, 6])
                                )
                        )

                    Spacer()
                }
            }
        }
        .buttonStyle(.plain)
        .transition(.opacity)
        .accessibilityLabel("\(exercise.cameraView.rawValue). \(config.positioningGuideText)")
        .accessibilityHint("Double tap to dismiss the guide")
    }
}

#Preview {
    PCPositioningGuideView(
        exercise: PCExercise.all[0],
        onDismiss: {}
    )
}
