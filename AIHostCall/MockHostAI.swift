import Foundation

struct MockHostAI: HostAIProcessing {
    func generateReply(for input: String, hostType: HostType, history: [ConversationMessage]) async throws -> String {
        try await Task.sleep(nanoseconds: 140_000_000)

        let cleanInput = input.trimmingCharacters(in: .whitespacesAndNewlines)
        let topic = cleanInput.count > 14 ? String(cleanInput.prefix(14)) : cleanInput
        let hasQuestion = cleanInput.contains("？") || cleanInput.contains("?")

        switch hostType {
        case .gentle:
            if hasQuestion {
                return "うん、いい質問だね。僕は、今の君の感じ方をもう少し聞きたいな。"
            }
            return "うん、ちゃんと伝わってるよ。\(topic)のこと、もう少し聞いてもいい？"
        case .strong:
            if hasQuestion {
                return "答えは焦らなくていい。まずは俺に、今いちばん引っかかってる所を言って。"
            }
            return "いいじゃん。そういう本音、嫌いじゃない。次は俺に何を言いたい？"
        case .dogLike:
            if hasQuestion {
                return "いいよ、聞いてくれてうれしい。ねえ、君はどう思った？"
            }
            return "それ聞けてうれしい。もっと知りたい、今どんな気分？"
        case .menchika:
            if hasQuestion {
                return "それ聞かれるの、ちょっと照れる。ねえ、君は俺にどう返してほしい？"
            }
            return "その言い方、ちょっと刺さった。ねえ、俺にはもう少し甘えてみる？"
        case .president:
            if hasQuestion {
                return "良い問いだね。答えを急がず、君の本音から決めよう。"
            }
            return "いい視点だね。君の言葉には芯がある。次はどう動きたい？"
        }
    }
}
