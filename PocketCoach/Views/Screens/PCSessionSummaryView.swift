//
//  PCSessionSummaryView.swift
//  PocketCoach
//

/// Summary screen presenting aggregate workout metrics, repetition accuracy, and guidance feedback
/// styled with the Lamborghini Design System's cathedral of darkness and sharp 0px geometry.
struct PCSessionSummaryView: View {
    @Environment(\.pcConfiguration) private var config
    @StateObject private var viewModel: PCSessionSummaryViewModel

    /// Closure to initiate another set of the same exercise.
    let onAnotherSet: () -> Void

    /// Closure to navigate back to the exercise selection catalog.
    let onChangeExercise: () -> Void

    /// Closure concluding the workout experience.
    let onDone: () -> Void

    @MainActor
    init(
        viewModel: PCSessionSummaryViewModel,
        onAnotherSet: @escaping () -> Void,
        onChangeExercise: @escaping () -> Void,
        onDone: @escaping () -> Void
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onAnotherSet = onAnotherSet
        self.onChangeExercise = onChangeExercise
        self.onDone = onDone
    }

    var body: some View {
        ZStack {
            backgroundLayer

            VStack(spacing: 0) {
                headerBar

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        heroAchievementBadge
                        metricsGrid
                        coachingFeedbackCard
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 24)
                }

                actionButtonsFooter
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
            }
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Subviews & Layout
extension PCSessionSummaryView {
    /// Pure pitch-black canvas adhering to the zero-gradient surface philosophy.
    private var backgroundLayer: some View {
        Color.pcLamboBlack
            .ignoresSafeArea()
    }

    /// Clean, high-contrast header bar with exercise title and sharp dismiss control.
    private var headerBar: some View {
        VStack(spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(config.summaryTitle)
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(.white)

                    Text(viewModel.exerciseName)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color.pcLamboGoldText)
                }

                Spacer()

                // Sharp Dismiss Button (0px Ghost Square)
                Button(action: onDone) {
                    ZStack {
                        Rectangle()
                            .fill(Color.pcLamboDarkIron)
                            .frame(width: 36, height: 36)
                            .border(Color.white.opacity(0.2), width: 1)

                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .frame(minWidth: 44, minHeight: 44)
                    .contentShape(Rectangle())
                }
                .accessibilityLabel(NSLocalizedString("pc_close_accessibility", tableName: "PocketCoach", bundle: .main, value: "Close Pocket Coach", comment: ""))
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)

            Rectangle()
                .fill(Color.pcLamboDarkIron)
                .frame(height: 1)
        }
    }

    /// Hexagonal achievement badge reflecting completion of the training set.
    private var heroAchievementBadge: some View {
        ZStack {
            PCHexagonShape()
                .stroke(Color.pcLamboGold.opacity(0.8), lineWidth: 1.5)
                .frame(width: 64, height: 58)

            PCHexagonShape()
                .fill(Color.pcLamboDarkIron)
                .frame(width: 54, height: 48)

            Image(systemName: "checkmark")
                .font(.system(size: 24, weight: .heavy))
                .foregroundColor(Color.pcLamboGold)
        }
        .padding(.vertical, 8)
    }

    /// 2x2 performance metric grid with sharp 0px corners and elevated charcoal surfaces.
    private var metricsGrid: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                metricCard(
                    title: NSLocalizedString("pc_summary_total_reps", tableName: "PocketCoach", bundle: .main, value: "Total Reps", comment: ""),
                    value: viewModel.totalRepsText,
                    iconName: "flag.checkered",
                    accentColor: .white
                )

                metricCard(
                    title: NSLocalizedString("pc_summary_clean_reps", tableName: "PocketCoach", bundle: .main, value: "Clean Reps", comment: ""),
                    value: viewModel.cleanRepsText,
                    iconName: "checkmark.seal.fill",
                    accentColor: Color.pcLamboGold
                )
            }

            HStack(spacing: 12) {
                metricCard(
                    title: NSLocalizedString("pc_summary_form_errors", tableName: "PocketCoach", bundle: .main, value: "Reps with Errors", comment: ""),
                    value: viewModel.formErrorsText,
                    iconName: "exclamationmark.triangle.fill",
                    accentColor: viewModel.result.repsWithErrors > 0 ? Color.pcError : Color.pcLamboAsh
                )

                metricCard(
                    title: NSLocalizedString("pc_summary_duration", tableName: "PocketCoach", bundle: .main, value: "Duration", comment: ""),
                    value: viewModel.formattedDuration,
                    iconName: "clock.fill",
                    accentColor: Color.pcLamboCyanPulse
                )
            }
        }
    }

    private func metricCard(title: String, value: String, iconName: String, accentColor: Color) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: iconName)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(accentColor)
                Spacer()
            }

            Text(value)
                .font(.system(size: 28, weight: .heavy))
                .foregroundColor(.white)

            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(Color.pcLamboAsh)
                .lineLimit(1)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.pcLamboCharcoal)
        .border(Color.pcLamboDarkIron, width: 1)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(value)")
    }

    /// Coaching feedback card highlighting detected form corrections or clean performance.
    private var coachingFeedbackCard: some View {
        HStack(alignment: .top, spacing: 12) {
            Rectangle()
                .fill(viewModel.result.repsWithErrors > 0 ? Color.pcWarning : Color.pcLamboGold)
                .frame(width: 3)

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 12))
                        .foregroundColor(Color.pcLamboGoldText)

                    Text(NSLocalizedString("pc_summary_common_error", tableName: "PocketCoach", bundle: .main, value: "Most Common Error", comment: ""))
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Color.pcLamboAsh)
                }

                Text(viewModel.mostCommonErrorText)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(3)
                    .lineSpacing(2)
            }

            Spacer(minLength: 0)
        }
        .padding(.vertical, 14)
        .padding(.trailing, 14)
        .background(Color.pcLamboCharcoal)
        .border(Color.pcLamboDarkIron, width: 1)
    }

    /// Action buttons footer styled with sharp Lamborghini Gold and transparent ghost buttons.
    private var actionButtonsFooter: some View {
        VStack(spacing: 12) {
            // Primary Action: Another Set
            Button(action: onAnotherSet) {
                HStack(spacing: 10) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 15, weight: .bold))
                    Text(config.anotherSetButtonTitle)
                        .font(.system(size: 15, weight: .bold))
                }
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
            }
            .buttonStyle(PCLamboGoldButtonStyle())

            // Secondary Action: Change Exercise (if allowed)
            if viewModel.canChangeExercise {
                Button(action: onChangeExercise) {
                    HStack(spacing: 10) {
                        Image(systemName: "list.bullet")
                            .font(.system(size: 14, weight: .bold))
                        Text(config.changeExerciseButtonTitle)
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .border(Color.white.opacity(0.4), width: 1)
                }
                .buttonStyle(PCLamboGhostButtonStyle())
            }

            // Dismiss Action: Done
            Button(action: onDone) {
                Text(config.doneButtonTitle)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color.pcLamboAsh)
                    .underline()
                    .frame(maxWidth: .infinity)
                    .frame(height: 36)
            }
        }
    }
}

#Preview {
    let mockResult = PCSessionResult(
        exercise: PCExercise(
            id: "squat",
            name: "Bodyweight Squats",
            systemImageName: "figure.strengthtraining.traditional",
            cameraView: .side,
            instructions: "Form guidance."
        ),
        completedReps: 12,
        repsWithErrors: 3,
        mostCommonError: "Knees caving inward during ascent",
        duration: 94.0
    )

    PCSessionSummaryView(
        viewModel: PCSessionSummaryViewModel(result: mockResult, canChangeExercise: true),
        onAnotherSet: {},
        onChangeExercise: {},
        onDone: {}
    )
}
