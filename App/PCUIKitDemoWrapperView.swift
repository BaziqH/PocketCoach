//
//  PCUIKitDemoWrapperView.swift
//  PocketCoach
//

/// SwiftUI wrapper around UIKitDemoViewController for modal sheet host integration testing.
struct PCUIKitDemoWrapperView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIKitDemoViewController {
        UIKitDemoViewController()
    }

    func updateUIViewController(_ uiViewController: UIKitDemoViewController, context: Context) {}
}
