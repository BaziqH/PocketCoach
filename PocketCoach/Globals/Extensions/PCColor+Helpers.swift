//
//  PCColor+Helpers.swift
//  PocketCoach
//

/// Convenience color palette extensions for Pocket Coach with prefixed members.
extension Color {
    /// Primary brand accent color.
    static let pcAccent = Color(red: 0.20, green: 0.60, blue: 1.00)

    /// Success color indicating good posture or completed repetition.
    static let pcSuccess = Color(red: 0.20, green: 0.82, blue: 0.48)

    /// Warning color indicating minor deviation or preparation status.
    static let pcWarning = Color(red: 1.00, green: 0.76, blue: 0.15)

    /// Error color indicating form failure or invalid posture.
    static let pcError = Color(red: 1.00, green: 0.27, blue: 0.27)

    /// Neutral color for poor tracking state or inactive guides.
    static let pcNeutral = Color(red: 0.70, green: 0.72, blue: 0.78)

    /// Deep dark background color for live session cards and sheets.
    static let pcBackground = Color(red: 0.07, green: 0.08, blue: 0.11)

    /// Card background surface color.
    static let pcCardBackground = Color(red: 0.13, green: 0.15, blue: 0.20)

    /// Secondary card stroke or subtle border color.
    static let pcCardBorder = Color(red: 0.22, green: 0.25, blue: 0.32)

    /// Top gradient surface color for depth in cards.
    static let pcCardGradientTop = Color(red: 0.14, green: 0.16, blue: 0.22)

    /// Bottom gradient surface color for depth in cards.
    static let pcCardGradientBottom = Color(red: 0.09, green: 0.10, blue: 0.14)

    /// Subtle highlight border sheen for cards.
    static let pcCardHighlight = Color.white.opacity(0.12)

    // MARK: - Lamborghini Design System Tokens

    /// Signature Lamborghini Gold (#FFC000) for primary CTAs and critical accents.
    static let pcLamboGold = Color(red: 1.0, green: 0.753, blue: 0.0)

    /// Dark amber-gold (#917300) for button pressed states.
    static let pcLamboDarkGold = Color(red: 0.569, green: 0.451, blue: 0.0)

    /// Lighter gold variant (#FFCE3E) for highlighted labels.
    static let pcLamboGoldText = Color(red: 1.0, green: 0.808, blue: 0.243)

    /// True uncompromising pitch black (#000000) surface.
    static let pcLamboBlack = Color(red: 0.0, green: 0.0, blue: 0.0)

    /// Charcoal (#202020) elevated surface for panels and cards.
    static let pcLamboCharcoal = Color(red: 0.125, green: 0.125, blue: 0.125)

    /// Dark iron (#181818) for deep section dividers and nested containers.
    static let pcLamboDarkIron = Color(red: 0.094, green: 0.094, blue: 0.094)

    /// Electric cyan pulse (#29ABE2) for vision AI telemetry highlights.
    static let pcLamboCyanPulse = Color(red: 0.161, green: 0.671, blue: 0.886)

    /// Mid-range ash gray (#7D7D7D) for metadata, labels, and muted text.
    static let pcLamboAsh = Color(red: 0.490, green: 0.490, blue: 0.490)

    /// Steel gray (#969696) for secondary badges and subtle borders.
    static let pcLamboSteel = Color(red: 0.588, green: 0.588, blue: 0.588)
}
