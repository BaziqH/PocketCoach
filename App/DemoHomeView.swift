//
//  DemoHomeView.swift
//  PocketCoach
//

/// Standalone dashboard with a clean, high-end consumer fitness aesthetic inspired by Apple Fitness+ and Whoop.
struct DemoHomeView: View {
    @State private var isShowingSwiftUIPocketCoach = false
    @State private var isShowingUIKitPocketCoach = false
    @State private var lastCompletedResult: PCSessionResult?

    var body: some View {
        ZStack {
            backgroundLayer

            GeometryReader { geometry in
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        Spacer(minLength: 32)

                        heroBrandingSection
                            .padding(.horizontal, 24)

                        if let result = lastCompletedResult {
                            recentWorkoutSection(result: result)
                                .padding(.horizontal, 24)
                                .padding(.top, 28)
                        }

                        Spacer(minLength: 40)

                        launchControlsSection
                            .padding(.horizontal, 24)
                            .padding(.bottom, 24)
                    }
                    .frame(minHeight: geometry.size.height)
                }
            }
        }
        .fullScreenCover(isPresented: $isShowingSwiftUIPocketCoach) {
            PocketCoachView { result in
                lastCompletedResult = result
                isShowingSwiftUIPocketCoach = false
            }
        }
        .sheet(isPresented: $isShowingUIKitPocketCoach) {
            PCUIKitDemoWrapperView()
        }
    }
}

// MARK: - Subviews & Layout
extension DemoHomeView {
    /// Deep black background layer providing uncompromising contrast.
    private var backgroundLayer: some View {
        Color.pcLamboBlack
            .ignoresSafeArea()
    }

    /// Centered brand identity with clean typography and generous breathing room.
    private var heroBrandingSection: some View {
        VStack(spacing: 20) {
            // Hero Brand Emblem
            ZStack {
                Rectangle()
                    .fill(Color.pcLamboCharcoal)
                    .frame(width: 80, height: 80)
                    .border(Color.pcLamboGold.opacity(0.8), width: 1.5)

                Image(systemName: "figure.strengthtraining.traditional")
                    .font(.system(size: 36, weight: .semibold))
                    .foregroundColor(Color.pcLamboGold)
            }

            VStack(spacing: 8) {
                Text("Pocket Coach")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)

                Text("Real-time AI form analysis and repetition tracking right from your camera.")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(Color.pcLamboAsh)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .padding(.horizontal, 16)
            }
        }
    }

    /// Clean, consumer-friendly workout evaluation card displayed after a completed session.
    private func recentWorkoutSection(result: PCSessionResult) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Recent Workout")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color.pcLamboAsh)

                Spacer()

                Text(result.exercise.name)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color.pcLamboGoldText)
            }

            let cleanReps = max(0, result.completedReps - result.repsWithErrors)
            HStack(spacing: 12) {
                metricColumn(label: "Total Reps", value: "\(result.completedReps)", color: .white)
                metricColumn(label: "Clean Reps", value: "\(cleanReps)", color: Color.pcLamboGold)
                metricColumn(label: "Errors", value: "\(result.repsWithErrors)", color: result.repsWithErrors > 0 ? Color.pcError : Color.pcLamboAsh)
            }

            if let error = result.mostCommonError {
                HStack(spacing: 8) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 12))
                        .foregroundColor(Color.pcLamboGoldText)

                    Text("Focus: \(error)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color.pcLamboGoldText)
                }
                .padding(.top, 2)
            }
        }
        .padding(18)
        .background(Color.pcLamboCharcoal)
        .border(Color.pcLamboDarkIron, width: 1)
    }

    private func metricColumn(label: String, value: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(color)

            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(Color.pcLamboAsh)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Color.pcLamboDarkIron)
    }

    /// Streamlined action controls with a prominent primary button and subtle secondary testing trigger.
    private var launchControlsSection: some View {
        VStack(spacing: 16) {
            // Primary Action: Start Workout
            Button {
                isShowingSwiftUIPocketCoach = true
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 14, weight: .bold))

                    Text("Start Workout")
                        .font(.system(size: 16, weight: .bold))
                }
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
            }
            .buttonStyle(PCLamboGoldButtonStyle())

            // Secondary Action: Minimalist UIKit Test Option
            Button {
                isShowingUIKitPocketCoach = true
            } label: {
                Text("UIKit Host Demo")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color.pcLamboAsh)
                    .underline()
                    .padding(.vertical, 6)
            }
        }
    }
}

#Preview {
    DemoHomeView()
}
