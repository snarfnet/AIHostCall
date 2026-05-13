import SwiftUI

enum AppRoute: Hashable {
    case call(HostType)
    case result(ConversationSession)
}

struct ContentView: View {
    @StateObject private var store = ConversationStore()
    @State private var path: [AppRoute] = []

    var body: some View {
        VStack(spacing: 0) {
            AdMobBannerSlotView(placement: .top)
                .background(HostCallDesign.background)

            NavigationStack(path: $path) {
                HomeView(path: $path)
                    .navigationDestination(for: AppRoute.self) { route in
                        switch route {
                        case .call(let hostType):
                            CallView(hostType: hostType, store: store, path: $path)
                        case .result(let session):
                            ResultView(session: session, path: $path)
                        }
                    }
            }

            AdMobBannerSlotView(placement: .bottom)
                .background(HostCallDesign.background)
        }
        .preferredColorScheme(.dark)
    }
}
