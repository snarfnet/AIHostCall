import SwiftUI

enum HostCallDesign {
    static let background = Color(red: 0.03, green: 0.025, blue: 0.02)
    static let panel = Color(red: 0.09, green: 0.075, blue: 0.055)
    static let panel2 = Color(red: 0.14, green: 0.11, blue: 0.075)
    static let gold = Color(red: 0.96, green: 0.72, blue: 0.28)
    static let softGold = Color(red: 1.0, green: 0.88, blue: 0.55)
    static let text = Color.white
    static let subtext = Color.white.opacity(0.68)
}

struct GoldButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.black)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(HostCallDesign.gold.opacity(configuration.isPressed ? 0.78 : 1))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(HostCallDesign.softGold)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(HostCallDesign.panel.opacity(configuration.isPressed ? 0.7 : 1))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(HostCallDesign.gold.opacity(0.45), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

struct HostPanel<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(16)
            .background(HostCallDesign.panel)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(HostCallDesign.gold.opacity(0.18), lineWidth: 1)
            )
    }
}

struct HostBackdrop: View {
    var body: some View {
        ZStack {
            HostCallDesign.background.ignoresSafeArea()
            LinearGradient(
                colors: [
                    HostCallDesign.gold.opacity(0.18),
                    .clear,
                    HostCallDesign.panel2.opacity(0.45)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        }
    }
}
