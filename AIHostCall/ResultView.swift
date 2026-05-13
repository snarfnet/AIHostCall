import SwiftUI

struct ResultView: View {
    let session: ConversationSession
    @Binding var path: [AppRoute]

    private var result: ConversationResult {
        ConversationScorer.makeResult(messages: session.messages, hostType: session.hostType)
    }

    var body: some View {
        ZStack {
            HostBackdrop()

            ScrollView {
                VStack(spacing: 18) {
                    VStack(spacing: 8) {
                        Text("会話結果")
                            .font(.largeTitle.bold())
                            .foregroundStyle(HostCallDesign.text)
                        Text(session.hostType.name)
                            .font(.headline)
                            .foregroundStyle(HostCallDesign.softGold)
                    }
                    .padding(.top, 14)

                    HostPanel {
                        VStack(spacing: 8) {
                            Text("\(result.score)")
                                .font(.system(size: 64, weight: .bold, design: .rounded))
                                .foregroundStyle(HostCallDesign.gold)
                            Text("会話スコア")
                                .font(.headline)
                                .foregroundStyle(HostCallDesign.subtext)
                        }
                        .frame(maxWidth: .infinity)
                    }

                    HostPanel {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("改善アドバイス")
                                .font(.headline)
                                .foregroundStyle(HostCallDesign.softGold)
                            Text(result.advice)
                                .foregroundStyle(HostCallDesign.text)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    HostPanel {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("次に使える一言")
                                .font(.headline)
                                .foregroundStyle(HostCallDesign.softGold)
                            Text(result.nextLine)
                                .font(.title3.bold())
                                .foregroundStyle(HostCallDesign.text)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    HostPanel {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("会話ログ")
                                .font(.headline)
                                .foregroundStyle(HostCallDesign.softGold)

                            if session.messages.isEmpty {
                                Text("まだ会話ログがありません。")
                                    .foregroundStyle(HostCallDesign.subtext)
                            } else {
                                ForEach(session.messages) { message in
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(message.role == .user ? "あなた" : session.hostType.shortName)
                                            .font(.caption.weight(.bold))
                                            .foregroundStyle(message.role == .user ? HostCallDesign.subtext : HostCallDesign.softGold)
                                        Text(message.text)
                                            .foregroundStyle(HostCallDesign.text)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    .padding(12)
                                    .background(message.role == .user ? HostCallDesign.panel2.opacity(0.85) : HostCallDesign.gold.opacity(0.12))
                                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    Button {
                        path.removeAll()
                    } label: {
                        Label("ホームへ戻る", systemImage: "house.fill")
                    }
                    .buttonStyle(GoldButtonStyle())
                }
                .padding(20)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}
