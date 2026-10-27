//
//  PCScaleButtonStyle.swift
//  PocketCoach
//

/// Button style providing an interactive tactile bounce scale animation on press.
struct PCScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}
