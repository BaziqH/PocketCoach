//
//  PCLamboGoldButtonStyle.swift
//  PocketCoach
//

/// Button style rendering a sharp Lamborghini Gold block with instant tactile pressed darkening.
struct PCLamboGoldButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ? Color.pcLamboDarkGold : Color.pcLamboGold)
            .animation(.easeInOut(duration: 0.12), value: configuration.isPressed)
    }
}
