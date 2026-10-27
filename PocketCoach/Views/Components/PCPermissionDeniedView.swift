//
//  PCPermissionDeniedView.swift
//  PocketCoach
//

/// Informative blocking screen presented when camera authorization is unavailable.
struct PCPermissionDeniedView: View {
    @Environment(\.pcConfiguration) private var config

    /// Optional closure allowing user to dismiss the camera experience.
    var onClose: (() -> Void)?

    var body: some View {
        ZStack {
            Color.pcBackground.ignoresSafeArea()

            VStack(spacing: 28) {
                if let onClose = onClose {
                    HStack {
                        Spacer()
                        Button(action: onClose) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 28))
                                .foregroundColor(Color.white.opacity(0.7))
                        }
                        .padding(.trailing, 20)
                        .padding(.top, 16)
                    }
                }

                Spacer()

                ZStack {
                    Circle()
                        .fill(config.errorColor.opacity(0.15))
                        .frame(width: 96, height: 96)

                    Image(systemName: "camera.badge.ellipsis")
                        .font(.system(size: 42))
                        .foregroundColor(config.errorColor)
                }

                VStack(spacing: 12) {
                    Text(config.cameraAccessNeededTitle)
                        .font(config.titleFont)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)

                    Text(config.cameraAccessNeededMessage)
                        .font(config.bodyFont)
                        .foregroundColor(config.neutralColor)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }

                Button(action: openSettings) {
                    Text(config.openSettingsButtonTitle)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(config.accentColor)
                        .cornerRadius(14)
                }
                .padding(.horizontal, 36)
                .accessibilityLabel(config.openSettingsButtonTitle)

                Spacer()
            }
        }
    }

    private func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}

#Preview {
    PCPermissionDeniedView(onClose: {})
}
