//
//  PCCameraPreviewContainerUIView.swift
//  PocketCoach
//

/// Custom UIView subclass whose backing layer is an AVCaptureVideoPreviewLayer.
final class PCCameraPreviewContainerUIView: UIView {
    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }

    /// Backing AVCaptureVideoPreviewLayer safely casted.
    var previewLayer: AVCaptureVideoPreviewLayer? {
        layer as? AVCaptureVideoPreviewLayer
    }

    /// Attaches the capture session to the preview layer and configures aspect fill.
    func bind(session: AVCaptureSession?) {
        guard let preview = previewLayer else { return }
        preview.session = session
        preview.videoGravity = .resizeAspectFill
        if session == nil {
            preview.backgroundColor = UIColor(red: 0.08, green: 0.10, blue: 0.14, alpha: 1.0).cgColor
        }
    }
}
