//
//  PocketCoach.swift
//  PocketCoach
//

/// Entry point enum providing factory methods for UIKit hosts.
enum PocketCoach {
    /// Constructs a UIViewController modal hosting the complete Pocket Coach experience with default configuration.
    ///
    /// - Parameters:
    ///   - exercise: Optional pre-selected exercise to jump straight into live tracking.
    ///   - onFinish: Completion callback invoked when the user exits or finishes the session.
    /// - Returns: A modal-ready UIViewController wrapping the SwiftUI navigation stack.
    @MainActor
    static func makeViewController(
        exercise: PCExercise? = nil,
        onFinish: @escaping (PCSessionResult?) -> Void
    ) -> UIViewController {
        makeViewController(
            exercise: exercise,
            configuration: .default,
            onFinish: onFinish
        )
    }

    /// Constructs a UIViewController modal hosting the complete Pocket Coach experience with custom configuration.
    ///
    /// - Parameters:
    ///   - exercise: Optional pre-selected exercise to jump straight into live tracking.
    ///   - configuration: Customizable colors, typography, and localized copy.
    ///   - onFinish: Completion callback invoked when the user exits or finishes the session.
    /// - Returns: A modal-ready UIViewController wrapping the SwiftUI navigation stack.
    @MainActor
    static func makeViewController(
        exercise: PCExercise? = nil,
        configuration: PCConfiguration,
        onFinish: @escaping (PCSessionResult?) -> Void
    ) -> UIViewController {
        var hostingController: UIHostingController<PocketCoachView>?

        let wrappedOnFinish: (PCSessionResult?) -> Void = { result in
            hostingController?.dismiss(animated: true) {
                onFinish(result)
            }
        }

        let view = PocketCoachView(
            exercise: exercise,
            configuration: configuration,
            onFinish: wrappedOnFinish
        )

        let controller = UIHostingController(rootView: view)
        controller.modalPresentationStyle = .fullScreen
        hostingController = controller
        return controller
    }
}
