//
//  PCCameraPermissionService.swift
//  PocketCoach
//

/// Concrete production implementation of PCCameraPermissionServicing.
final class PCCameraPermissionService: PCCameraPermissionServicing {
    /// Evaluates camera permission while safely guarding against missing Info.plist keys.
    /// In the simulator, reports authorized immediately so testing flows without camera hardware.
    var status: PCCameraPermissionStatus {
        #if targetEnvironment(simulator)
        return .authorized
        #else
        guard Bundle.main.object(forInfoDictionaryKey: "NSCameraUsageDescription") != nil else {
            return .denied
        }

        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            return .authorized
        case .denied:
            return .denied
        case .restricted:
            return .restricted
        case .notDetermined:
            return .notDetermined
        @unknown default:
            return .denied
        }
        #endif
    }

    /// Asynchronously requests camera access with continuation bridging.
    /// In the simulator, automatically returns true.
    func requestPermission() async -> Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        guard Bundle.main.object(forInfoDictionaryKey: "NSCameraUsageDescription") != nil else {
            return false
        }

        return await withCheckedContinuation { continuation in
            AVCaptureDevice.requestAccess(for: .video) { granted in
                continuation.resume(returning: granted)
            }
        }
        #endif
    }
}
