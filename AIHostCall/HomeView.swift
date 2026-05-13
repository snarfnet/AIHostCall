import SwiftUI

struct HomeView: View {
    @Binding var path: [AppRoute]
    @State private var selectedHost: HostType = .gentle

    var body: some View {
        ZStack {
            HostBackdrop()

            VStack(spacing: 26) {
                Spacer(minLength: 18)

                VStack(spacing: 10) {
                    Text("ホスコール")
                        .font(.system(size: 38, weight: .bold, design: .rounded))
                        .foregroundStyle(HostCallDesign.text)
                        .multilineTextAlignment(.center)

                    Text("声で話して、短く返ってくる。無料構成の会話練習MVP。")
                        .font(.subheadline)
                        .foregroundStyle(HostCallDesign.subtext)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 12)
                }

                HostPanel {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("ホストタイプ")
                            .font(.headline)
                            .foregroundStyle(HostCallDesign.softGold)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                            ForEach(HostType.allCases) { host in
                                Button {
                                    selectedHost = host
                                } label: {
                                    Text(host.name)
                                        .font(.subheadline.weight(.semibold))
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.78)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 13)
                                        .background(selectedHost == host ? HostCallDesign.gold : HostCallDesign.panel2)
                                        .foregroundStyle(selectedHost == host ? .black : HostCallDesign.text)
                                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }

                HostPanel {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(selectedHost.name)
                            .font(.title3.bold())
                            .foregroundStyle(HostCallDesign.text)
                        Text(selectedHost.promptTone)
                            .font(.subheadline)
                            .foregroundStyle(HostCallDesign.subtext)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                Button {
                    path.append(.call(selectedHost))
                } label: {
                    Label("通話開始", systemImage: "phone.fill")
                }
                .buttonStyle(GoldButtonStyle())

                Spacer()
            }
            .padding(20)
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
