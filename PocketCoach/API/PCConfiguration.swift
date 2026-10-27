//
//  PCConfiguration.swift
//  PocketCoach
//

/// Customizable visual and textual configuration for the Pocket Coach UI.
struct PCConfiguration {
    /// Accent color used for buttons, active indicators, and highlights.
    var accentColor: Color

    /// Color indicating proper posture and successful repetitions.
    var successColor: Color

    /// Color indicating form errors or critical warnings.
    var errorColor: Color

    /// Color indicating warnings or alignment adjustments.
    var warningColor: Color

    /// Color used when tracking quality is poor or inactive.
    var neutralColor: Color

    /// Background surface color for list cards and overlay badges.
    var cardBackgroundColor: Color

    /// Title font for navigation bars and screen headers.
    var titleFont: Font

    /// Body font for instructions and secondary messages.
    var bodyFont: Font

    /// Callout font for form cues and live alerts.
    var cueFont: Font

    /// High-contrast numeric font for the repetition counter.
    var counterFont: Font

    /// Title displayed on the exercise selection screen.
    var exerciseListTitle: String

    /// Category badge headline displayed above the exercise title.
    var exerciseListCategoryBadge: String

    /// Subtitle description displayed on the exercise selection screen.
    var exerciseListSubtitle: String

    /// Title displayed when camera permissions are denied or restricted.
    var cameraAccessNeededTitle: String

    /// Explanatory message displayed when camera access is denied.
    var cameraAccessNeededMessage: String

    /// Button title navigating user to system application settings.
    var openSettingsButtonTitle: String

    /// Instructional text displayed over the positioning silhouette guide.
    var positioningGuideText: String

    /// Title for the button to conclude a live session.
    var finishButtonTitle: String

    /// Title for the session summary view.
    var summaryTitle: String

    /// Title for the button initiating another set of the same exercise.
    var anotherSetButtonTitle: String

    /// Title for the button allowing the user to select another exercise.
    var changeExerciseButtonTitle: String

    /// Title for the dismiss/done button on the summary screen.
    var doneButtonTitle: String

    /// Default configuration populated with localized resources.
    @MainActor
    static let `default` = PCConfiguration(
        accentColor: .pcAccent,
        successColor: .pcSuccess,
        errorColor: .pcError,
        warningColor: .pcWarning,
        neutralColor: .pcNeutral,
        cardBackgroundColor: .pcCardBackground,
        titleFont: .system(size: 24, weight: .bold, design: .rounded),
        bodyFont: .system(size: 16, weight: .medium, design: .default),
        cueFont: .system(size: 18, weight: .semibold, design: .rounded),
        counterFont: .system(size: 64, weight: .heavy, design: .rounded),
        exerciseListTitle: NSLocalizedString("pc_choose_exercise_title", tableName: "PocketCoach", bundle: .main, value: "Choose an exercise", comment: ""),
        exerciseListCategoryBadge: NSLocalizedString("pc_exercise_category_label", tableName: "PocketCoach", bundle: .main, value: "REAL-TIME AI COACH", comment: ""),
        exerciseListSubtitle: NSLocalizedString("pc_choose_exercise_subtitle", tableName: "PocketCoach", bundle: .main, value: "Select a movement for real-time camera form analysis", comment: ""),
        cameraAccessNeededTitle: NSLocalizedString("pc_camera_access_needed_title", tableName: "PocketCoach", bundle: .main, value: "Camera access needed", comment: ""),
        cameraAccessNeededMessage: NSLocalizedString("pc_camera_access_needed_message", tableName: "PocketCoach", bundle: .main, value: "Pocket Coach requires camera access to check your form in real-time.", comment: ""),
        openSettingsButtonTitle: NSLocalizedString("pc_open_settings_title", tableName: "PocketCoach", bundle: .main, value: "Open Settings", comment: ""),
        positioningGuideText: NSLocalizedString("pc_positioning_guide_text", tableName: "PocketCoach", bundle: .main, value: "Place the phone side-on, fit your whole body", comment: ""),
        finishButtonTitle: NSLocalizedString("pc_finish_set_title", tableName: "PocketCoach", bundle: .main, value: "Finish Set", comment: ""),
        summaryTitle: NSLocalizedString("pc_summary_title", tableName: "PocketCoach", bundle: .main, value: "Session Summary", comment: ""),
        anotherSetButtonTitle: NSLocalizedString("pc_another_set_title", tableName: "PocketCoach", bundle: .main, value: "Another set", comment: ""),
        changeExerciseButtonTitle: NSLocalizedString("pc_change_exercise_title", tableName: "PocketCoach", bundle: .main, value: "Change exercise", comment: ""),
        doneButtonTitle: NSLocalizedString("pc_done_title", tableName: "PocketCoach", bundle: .main, value: "Done", comment: "")
    )
}
