//
//  PCLamboGhostButtonStyle.swift
//  PocketCoach
//

/// Button style rendering a sharp transparent ghost button with hairline border and touch feedback.
struct PCLamboGhostButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ? Color.white.opacity(0.12) : Color.clear)
            .animation(.easeInOut(duration: 0.12), value: configuration.isPressed)
    }
}
