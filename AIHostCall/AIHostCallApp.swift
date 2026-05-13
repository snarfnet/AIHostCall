import SwiftUI
import GoogleMobileAds
import AppTrackingTransparency

@main
struct AIHostCallApp: App {
    init() {
        GADMobileAds.sharedInstance().start()
        Task { @MainActor in
            Self.requestTrackingAuthorizationIfNeeded()
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }

    private static func requestTrackingAuthorizationIfNeeded() {
        guard ATTrackingManager.trackingAuthorizationStatus == .notDetermined else { return }
        ATTrackingManager.requestTrackingAuthorization { _ in }
    }
}
