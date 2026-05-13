import SwiftUI
import GoogleMobileAds

enum AdPlacement {
    case top
    case bottom
}

struct AdService {
    static let shared = AdService()

    private let topBannerUnitID = "ca-app-pub-9404799280370656/9241665428"
    private let bottomBannerUnitID = "ca-app-pub-9404799280370656/9489077438"

    func bannerUnitID(for placement: AdPlacement) -> String {
        switch placement {
        case .top:
            topBannerUnitID
        case .bottom:
            bottomBannerUnitID
        }
    }
}

struct AdMobBannerSlotView: View {
    let placement: AdPlacement

    var body: some View {
        AdMobBannerView(unitID: AdService.shared.bannerUnitID(for: placement))
            .frame(height: 50)
            .frame(maxWidth: .infinity)
            .accessibilityLabel("広告")
    }
}

private struct AdMobBannerView: UIViewRepresentable {
    let unitID: String

    func makeUIView(context: Context) -> BannerView {
        let banner = BannerView(adSize: AdSizeBanner)
        banner.adUnitID = unitID

        DispatchQueue.main.async {
            if let rootViewController = UIApplication.shared.activeRootViewController {
                banner.rootViewController = rootViewController
                banner.load(Request())
            }
        }

        return banner
    }

    func updateUIView(_ uiView: BannerView, context: Context) {}
}

private extension UIApplication {
    var activeRootViewController: UIViewController? {
        connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first { $0.isKeyWindow }?
            .rootViewController
    }
}
