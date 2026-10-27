//
//  PocketCoachView.swift
//  PocketCoach
//

/// Primary SwiftUI entry point for embedding the Pocket Coach form checking feature.
struct PocketCoachView: View {
    @StateObject private var coordinator: PCCoordinator
    private let configuration: PCConfiguration

    /// Injected form engine factory or instance for production or test environments.
    private let formEngineProvider: (PCExercise) -> PCFormEngine

    /// Injected camera service factory for production, simulator, or test environments.
    private let cameraServiceFactory: () -> PCCameraService

    /// Initializes Pocket Coach SwiftUI experience with default configuration.
    @MainActor
    init(
        exercise: PCExercise? = nil,
        formEngineProvider: ((PCExercise) -> PCFormEngine)? = nil,
        cameraServiceFactory: (() -> PCCameraService)? = nil,
        onFinish: @escaping (PCSessionResult?) -> Void
    ) {
        self.init(
            exercise: exercise,
            configuration: .default,
            formEngineProvider: formEngineProvider,
            cameraServiceFactory: cameraServiceFactory,
            onFinish: onFinish
        )
    }

    /// Initializes Pocket Coach SwiftUI experience with custom configuration.
    @MainActor
    init(
        exercise: PCExercise? = nil,
        configuration: PCConfiguration,
        formEngineProvider: ((PCExercise) -> PCFormEngine)? = nil,
        cameraServiceFactory: (() -> PCCameraService)? = nil,
        onFinish: @escaping (PCSessionResult?) -> Void
    ) {
        _coordinator = StateObject(wrappedValue: PCCoordinator(initialExercise: exercise, onFinish: onFinish))
        self.configuration = configuration
        self.formEngineProvider = formEngineProvider ?? { PCMockFormEngine(exercise: $0) }
        self.cameraServiceFactory = cameraServiceFactory ?? {
            #if targetEnvironment(simulator)
            return PCMockCameraService()
            #else
            return PCAVCameraService()
            #endif
        }
    }

    @ViewBuilder
    var body: some View {
        if #available(iOS 16.0, *) {
            modernNavigationStack
        } else {
            legacyNavigationView
        }
    }

    // MARK: - iOS 16+ NavigationStack (No Deprecation Warnings)

    @available(iOS 16.0, *)
    private var modernNavigationStack: some View {
        NavigationStack {
            ZStack {
                Color.pcBackground.ignoresSafeArea()

                if coordinator.initialExerciseProvided, let exercise = coordinator.selectedExercise {
                    modernLiveSessionScreen(for: exercise)
                } else {
                    PCExerciseListView(
                        onSelectExercise: { exercise in
                            coordinator.startLiveSession(exercise: exercise)
                        },
                        onClose: {
                            coordinator.dismiss()
                        }
                    )
                }
            }
            .navigationDestination(isPresented: $coordinator.isLiveSessionActive) {
                if let exercise = coordinator.selectedExercise {
                    modernLiveSessionScreen(for: exercise)
                }
            }
            .navigationDestination(isPresented: $coordinator.isSummaryActive) {
                if let result = coordinator.sessionResult {
                    summaryScreen(for: result)
                }
            }
        }
        .environment(\.pcConfiguration, configuration)
    }

    @available(iOS 16.0, *)
    private func modernLiveSessionScreen(for exercise: PCExercise) -> some View {
        let liveViewModel = PCLiveSessionViewModel(
            exercise: exercise,
            engine: formEngineProvider(exercise),
            cameraService: cameraServiceFactory()
        )

        return PCLiveSessionView(
            viewModel: liveViewModel,
            onFinishSession: { result in
                coordinator.showSummary(result: result)
            },
            onClose: {
                coordinator.dismiss()
            }
        )
    }

    // MARK: - iOS 15.6 NavigationView Fallback (Stack Style)

    private var legacyNavigationView: some View {
        NavigationView {
            ZStack {
                Color.pcBackground.ignoresSafeArea()

                if coordinator.initialExerciseProvided, let exercise = coordinator.selectedExercise {
                    legacyLiveSessionScreen(for: exercise)
                } else {
                    legacyCatalogScreen
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(.stack)
        .environment(\.pcConfiguration, configuration)
    }

    private var legacyCatalogScreen: some View {
        ZStack {
            PCExerciseListView(
                onSelectExercise: { exercise in
                    coordinator.startLiveSession(exercise: exercise)
                },
                onClose: {
                    coordinator.dismiss()
                }
            )

            if let exercise = coordinator.selectedExercise {
                NavigationLink(value: exercise) {
                    EmptyView()
                }
                .hidden()
            }
        }
    }

    private func legacyLiveSessionScreen(for exercise: PCExercise) -> some View {
        let liveViewModel = PCLiveSessionViewModel(
            exercise: exercise,
            engine: formEngineProvider(exercise),
            cameraService: cameraServiceFactory()
        )

        return ZStack {
            PCLiveSessionView(
                viewModel: liveViewModel,
                onFinishSession: { result in
                    coordinator.showSummary(result: result)
                },
                onClose: {
                    coordinator.dismiss()
                }
            )

            if let result = coordinator.sessionResult {
                NavigationLink(value: result) {
                    EmptyView()
                }
                .hidden()
            }
        }
        .navigationBarHidden(true)
    }

    // MARK: - Shared Summary Screen

    private func summaryScreen(for result: PCSessionResult) -> some View {
        let summaryViewModel = PCSessionSummaryViewModel(
            result: result,
            canChangeExercise: coordinator.canChangeExercise
        )

        return PCSessionSummaryView(
            viewModel: summaryViewModel,
            onAnotherSet: {
                coordinator.repeatExercise()
            },
            onChangeExercise: {
                coordinator.returnToExerciseList()
            },
            onDone: {
                coordinator.complete()
            }
        )
        .navigationBarHidden(true)
    }
}

#Preview {
    PocketCoachView(onFinish: { _ in })
}
