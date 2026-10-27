//
//  PCExerciseListView.swift
//  PocketCoach
//

/// Primary exercise selection screen presenting supported movements with a clean consumer fitness aesthetic.
struct PCExerciseListView: View {
    @Environment(\.pcConfiguration) private var config
    @StateObject private var viewModel: PCExerciseListViewModel

    /// Closure invoked when an exercise card is tapped to begin workout.
    let onSelectExercise: (PCExercise) -> Void

    /// Closure invoked when the dismiss button is tapped.
    let onClose: () -> Void

    /// Initializes exercise selection view with an explicit view model.
    @MainActor
    init(
        viewModel: PCExerciseListViewModel,
        onSelectExercise: @escaping (PCExercise) -> Void,
        onClose: @escaping () -> Void
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onSelectExercise = onSelectExercise
        self.onClose = onClose
    }

    /// Initializes exercise selection view with the default view model.
    @MainActor
    init(
        onSelectExercise: @escaping (PCExercise) -> Void,
        onClose: @escaping () -> Void
    ) {
        _viewModel = StateObject(wrappedValue: PCExerciseListViewModel())
        self.onSelectExercise = onSelectExercise
        self.onClose = onClose
    }

    var body: some View {
        ZStack {
            backgroundLayer

            VStack(spacing: 0) {
                headerBar

                ScrollView(showsIndicators: false) {
                    exerciseCardList
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                        .padding(.bottom, 28)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            viewModel.loadExercises()
        }
    }
}

// MARK: - Subviews & Layout
extension PCExerciseListView {
    /// Uncompromising deep black background canvas.
    private var backgroundLayer: some View {
        Color.pcLamboBlack
            .ignoresSafeArea()
    }

    /// Clean, minimalist header with a single title hierarchy and dismiss button.
    private var headerBar: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(config.exerciseListTitle)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)

                Text(config.exerciseListSubtitle)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Color.pcLamboAsh)
            }

            Spacer()

            // Dismiss Button
            Button(action: onClose) {
                ZStack {
                    Rectangle()
                        .fill(Color.pcLamboDarkIron)
                        .frame(width: 36, height: 36)
                        .border(Color.white.opacity(0.18), width: 1)

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
        .padding(.bottom, 12)
    }

    /// Vertical list of exercise selection cards with spring interactions.
    private var exerciseCardList: some View {
        LazyVStack(spacing: 12) {
            ForEach(viewModel.exercises) { exercise in
                Button {
                    onSelectExercise(exercise)
                } label: {
                    PCExerciseCardView(exercise: exercise)
                }
                .buttonStyle(PCScaleButtonStyle())
            }
        }
    }
}

#Preview {
    PCExerciseListView(
        onSelectExercise: { _ in },
        onClose: {}
    )
}
