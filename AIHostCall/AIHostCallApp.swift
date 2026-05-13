import SwiftUI
import GoogleMobileAds
import AppTrackingTransparency

@main
struct AIHostCallApp: App {
    init() {
        MobileAds.shared.start()
        Task { @MainActor in
            requestTrackingAuthorizationIfNeeded()
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }

    private func requestTrackingAuthorizationIfNeeded() {
        guard ATTrackingManager.trackingAuthorizationStatus == .notDetermined else { return }
        ATTrackingManager.requestTrackingAuthorization { _ in }
    }
}
