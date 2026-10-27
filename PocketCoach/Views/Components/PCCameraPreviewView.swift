//
//  PCCameraPreviewView.swift
//  PocketCoach
//

// UIKit is required because SwiftUI has no native view backed by AVCaptureVideoPreviewLayer for hardware camera rendering.
struct PCCameraPreviewView: UIViewRepresentable {
    /// Injected camera service supplying the active capture session.
    let service: PCCameraService

    func makeUIView(context: Context) -> PCCameraPreviewContainerUIView {
        let view = PCCameraPreviewContainerUIView()
        view.bind(session: service.captureSession)
        return view
    }

    func updateUIView(_ uiView: PCCameraPreviewContainerUIView, context: Context) {
        if uiView.previewLayer?.session !== service.captureSession {
            uiView.bind(session: service.captureSession)
        }
    }
}

#Preview {
    PCCameraPreviewView(service: PCMockCameraService())
}
