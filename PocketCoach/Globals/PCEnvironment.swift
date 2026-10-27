//
//  PCEnvironment.swift
//  PocketCoach
//

/// Environment key for injecting PCConfiguration.
@MainActor
private struct PCConfigurationEnvironmentKey: EnvironmentKey {
    static var defaultValue: PCConfiguration {
        .default
    }
}

/// Environment extension providing access to the current PCConfiguration.
extension EnvironmentValues {
    /// Injected Pocket Coach configuration.
    var pcConfiguration: PCConfiguration {
        get { self[PCConfigurationEnvironmentKey.self] }
        set { self[PCConfigurationEnvironmentKey.self] = newValue }
    }
}
