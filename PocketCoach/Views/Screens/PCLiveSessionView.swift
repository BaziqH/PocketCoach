//
//  PCLiveSessionView.swift
//  PocketCoach
//

/// Full-screen live coaching view combining camera feed, skeleton overlay, and real-time guidance
/// styled with the Lamborghini Design System's cathedral of darkness and sharp 0px geometry.
struct PCLiveSessionView: View {
    @Environment(\.pcConfiguration) private var config
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var viewModel: PCLiveSessionViewModel
    @State private var isFinishExpanded: Bool = false

    /// Closure invoked when the user concludes their workout set.
    let onFinishSession: (PCSessionResult) -> Void

    /// Closure invoked when the user exits the live session early.
    let onClose: () -> Void

    @MainActor
    init(
        viewModel: PCLiveSessionViewModel,
        onFinishSession: @escaping (PCSessionResult) -> Void,
        onClose: @escaping () -> Void
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onFinishSession = onFinishSession
        self.onClose = onClose
    }

    var body: some View {
        ZStack {
            Color.pcLamboBlack.ignoresSafeArea()

            // State A: Camera Permission Denied or Restricted
            if viewModel.cameraPermissionStatus == .denied || viewModel.cameraPermissionStatus == .restricted {
                PCPermissionDeniedView(onClose: onClose)
            } else {
                // State B: Active Camera Live Session
                liveSessionLayer
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            UIApplication.shared.isIdleTimerDisabled = true
            Task {
                await viewModel.onAppear()
            }
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
            Task {
                await viewModel.onDisappear()
            }
        }
        .onChange(of: scenePhase) { phase in
            if phase == .background {
                viewModel.pause()
            } else if phase == .active {
                viewModel.resume()
            }
        }
    }
}

// MARK: - Live Session Overlays
extension PCLiveSessionView {
    /// Composite camera preview, skeletal tracking, HUD telemetry, and guidance layers.
    private var liveSessionLayer: some View {
        ZStack {
            // Layer 1: Hardware Video Preview
            PCCameraPreviewView(service: viewModel.cameraService)
                .ignoresSafeArea()

            // Layer 2: Real-time Skeletal Mesh Overlay (active once setup tip concludes)
            if !viewModel.isPositioningGuideVisible {
                PCSkeletonOverlayView(
                    jointStates: viewModel.jointStates,
                    trackingQuality: viewModel.trackingQuality
                )
                .ignoresSafeArea()
            }

            // Layer 3: Controls and Feedback UI Overlays (Full Screen HUD)
            VStack(spacing: 0) {
                topBarView
                    .padding(.horizontal, 20)
                    .padding(.top, 12)

                // Tracking Quality Status Indicator & Debug Overlay (active once tracking starts)
                if !viewModel.isPositioningGuideVisible {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 8) {
                            PCTrackingBadgeView(quality: viewModel.trackingQuality)

                            #if DEBUG
                            PCCameraDebugOverlayView(metrics: viewModel.debugMetrics)
                            #endif
                        }

                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                }

                if viewModel.cameraState == .interrupted {
                    cameraInterruptedNotice
                        .padding(.top, 8)
                }

                Spacer()

                // Form Correction Cue Alert Banner (shown only when tracking is active)
                if !viewModel.isPositioningGuideVisible {
                    PCCueBannerView(cue: viewModel.currentCue)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 16)

                    // Repetition Counter
                    PCRepCounterView(count: viewModel.repCount)
                        .padding(.bottom, 16)
                }

                // Expandable Finish Workout Set Control
                finishControl
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)
            }

            // Layer 4: Initial Camera Setup Pop-up Modal (appears for 2–3s at the start)
            if viewModel.isPositioningGuideVisible {
                cameraSetupPopupModal
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .scale(scale: 0.95)),
                        removal: .opacity.combined(with: .scale(scale: 0.95))
                    ))
                    .zIndex(10)
            }
        }
    }

    /// Floating pop-up modal presenting camera placement guidance before tracking unpauses.
    private var cameraSetupPopupModal: some View {
        ZStack {
            // Subtle backdrop scrim with tap-to-dismiss
            Color.black.opacity(0.50)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        viewModel.dismissPositioningGuide()
                    }
                }

            // Floating Pop-up Card
            VStack(alignment: .leading, spacing: 14) {
                // Top Tag & Manual Close
                HStack(alignment: .center) {
                    HStack(spacing: 8) {
                        ZStack {
                            Rectangle()
                                .fill(Color.pcLamboDarkIron)
                                .frame(width: 32, height: 32)
                                .border(Color.pcLamboGold.opacity(0.6), width: 1)

                            Image(systemName: "camera.viewfinder")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(Color.pcLamboGold)
                        }

                        Text("CAMERA SETUP")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(Color.pcLamboGoldText)
                            .tracking(1.2)
                    }

                    Spacer()

                    Button {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            viewModel.dismissPositioningGuide()
                        }
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Color.pcLamboAsh)
                            .padding(6)
                    }
                    .accessibilityLabel(NSLocalizedString("pc_close_accessibility", tableName: "PocketCoach", bundle: .main, value: "Dismiss", comment: ""))
                }

                // Body Guidance
                VStack(alignment: .leading, spacing: 6) {
                    Text(NSLocalizedString("pc_setup_tip_title", tableName: "PocketCoach", bundle: .main, value: "Camera Setup Tip", comment: ""))
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)

                    Text(NSLocalizedString("pc_setup_tip_body", tableName: "PocketCoach", bundle: .main, value: "Place your phone at hip height 6–8 ft away for automatic pose tracking.", comment: ""))
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(Color.pcLamboAsh)
                        .lineSpacing(2)
                }

                // Perspective Hint & Auto-start Status
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: "iphone.gen3")
                            .font(.system(size: 11))
                            .foregroundColor(Color.pcLamboGold)
                        Text(viewModel.exercise.cameraView.rawValue.capitalized + " View")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.pcLamboDarkIron)
                    .border(Color.white.opacity(0.1), width: 1)

                    Spacer()

                    Text("Starting in 3s...")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color.pcLamboAsh)
                }
                .padding(.top, 4)
            }
            .padding(18)
            .frame(maxWidth: 330)
            .background(Color.pcLamboCharcoal)
            .border(Color.pcLamboDarkIron, width: 1)
            .overlay(
                Rectangle()
                    .fill(Color.pcLamboGold)
                    .frame(width: 3),
                alignment: .leading
            )
            .padding(.horizontal, 24)
        }
    }

    /// Sharp top bar containing dismiss action, active exercise indicator, and camera toggle.
    private var topBarView: some View {
        HStack {
            // Sharp Dismiss Button (0px Ghost Square)
            Button(action: onClose) {
                ZStack {
                    Rectangle()
                        .fill(Color.pcLamboDarkIron)
                        .frame(width: 36, height: 36)
                        .border(Color.white.opacity(0.3), width: 1)

                    Image(systemName: "xmark")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                }
                .frame(minWidth: 44, minHeight: 44)
                .contentShape(Rectangle())
            }
            .accessibilityLabel(NSLocalizedString("pc_close_accessibility", tableName: "PocketCoach", bundle: .main, value: "Close Pocket Coach", comment: ""))

            Spacer()

            // Exercise Title Tag
            HStack(spacing: 8) {
                Rectangle()
                    .fill(Color.pcLamboGold)
                    .frame(width: 3, height: 14)

                Text(viewModel.exercise.name)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(Color.pcLamboDarkIron)
            .border(Color.white.opacity(0.12), width: 1)

            Spacer()

            // Sharp Camera Flip Button
            Button {
                Task {
                    await viewModel.flipCamera()
                }
            } label: {
                ZStack {
                    Rectangle()
                        .fill(Color.pcLamboDarkIron)
                        .frame(width: 36, height: 36)
                        .border(Color.white.opacity(0.3), width: 1)

                    Image(systemName: "camera.rotate.fill")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                }
                .frame(minWidth: 44, minHeight: 44)
                .contentShape(Rectangle())
            }
            .accessibilityLabel(NSLocalizedString("pc_flip_camera_accessibility", tableName: "PocketCoach", bundle: .main, value: "Flip camera", comment: ""))
        }
    }

    /// Notice displayed when system interrupts camera capture.
    private var cameraInterruptedNotice: some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(Color.pcWarning)
            Text("Camera interrupted")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(Color.pcLamboDarkIron)
        .border(Color.pcWarning.opacity(0.5), width: 1)
    }

    /// Sharp finish control button initiating set completion with Lamborghini Gold and ghost styles.
    private var finishControl: some View {
        HStack(spacing: 12) {
            if isFinishExpanded {
                // Collapse / Cancel button
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                        isFinishExpanded = false
                    }
                } label: {
                    ZStack {
                        Rectangle()
                            .fill(Color.pcLamboDarkIron)
                            .frame(width: 52, height: 52)
                            .border(Color.white.opacity(0.3), width: 1)

                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .accessibilityLabel(NSLocalizedString("pc_close_accessibility", tableName: "PocketCoach", bundle: .main, value: "Cancel", comment: ""))

                // Full Finish Set Action Button
                Button {
                    Task {
                        let result = await viewModel.finishSession()
                        onFinishSession(result)
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 18, weight: .bold))

                        Text(config.finishButtonTitle)
                            .font(.system(size: 16, weight: .bold))
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                }
                .buttonStyle(PCLamboGoldButtonStyle())
                .transition(.scale(scale: 0.95).combined(with: .opacity))
            } else {
                Spacer()

                // Compact Sharp Gold Tick Button
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                        isFinishExpanded = true
                    }
                } label: {
                    ZStack {
                        Rectangle()
                            .fill(Color.pcLamboGold)
                            .frame(width: 50, height: 50)

                        Image(systemName: "checkmark")
                            .font(.system(size: 22, weight: .heavy))
                            .foregroundColor(.black)
                    }
                }
                .buttonStyle(PCLamboGoldButtonStyle())
                .transition(.scale(scale: 0.9).combined(with: .opacity))
                .accessibilityLabel(config.finishButtonTitle)
                .accessibilityHint("Tap to expand finish set button")
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.75), value: isFinishExpanded)
    }
}

#Preview {
    let mockExercise = PCExercise(
        id: "squat",
        name: "Bodyweight Squats",
        systemImageName: "figure.strengthtraining.traditional",
        cameraView: .side,
        instructions: "Keep knees in line with toes.",
        targetAngles: [.knee, .hip, .torsoLean]
    )
    let mockEngine = PCMockFormEngine(exercise: mockExercise)
    let mockCamera = PCMockCameraService()
    let viewModel = PCLiveSessionViewModel(
        exercise: mockExercise,
        engine: mockEngine,
        cameraService: mockCamera
    )

    PCLiveSessionView(
        viewModel: viewModel,
        onFinishSession: { _ in },
        onClose: {}
    )
}
