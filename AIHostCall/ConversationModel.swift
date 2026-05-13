import Foundation

enum HostType: String, CaseIterable, Identifiable, Codable, Hashable {
    case gentle
    case strong
    case dogLike
    case menchika
    case president

    var id: String { rawValue }

    var name: String {
        switch self {
        case .gentle: "優しいホスト"
        case .strong: "オラオラ系"
        case .dogLike: "犬系"
        case .menchika: "メン地下系"
        case .president: "社長系"
        }
    }

    var shortName: String {
        switch self {
        case .gentle: "優しい"
        case .strong: "オラオラ"
        case .dogLike: "犬系"
        case .menchika: "メン地下"
        case .president: "社長"
        }
    }

    var promptTone: String {
        switch self {
        case .gentle:
            "やわらかく、安心させる。相手の話を受け止める。"
        case .strong:
            "強めで自信がある。軽く引っ張る。きつく責めない。"
        case .dogLike:
            "明るく人懐っこい。相手を全力で喜ばせる。"
        case .menchika:
            "少し甘く、距離が近い。ライブ後の特典会のように短く返す。"
        case .president:
            "余裕があり、包容力がある。前向きに背中を押す。"
        }
    }

    var voiceProfile: HostVoiceProfile {
        switch self {
        case .gentle:
            HostVoiceProfile(rate: 0.42, pitch: 0.88, volume: 0.96)
        case .strong:
            HostVoiceProfile(rate: 0.43, pitch: 0.78, volume: 0.98)
        case .dogLike:
            HostVoiceProfile(rate: 0.48, pitch: 1.02, volume: 0.96)
        case .menchika:
            HostVoiceProfile(rate: 0.46, pitch: 0.95, volume: 0.94)
        case .president:
            HostVoiceProfile(rate: 0.41, pitch: 0.8, volume: 0.96)
        }
    }
}

enum SpeakerRole: String, Codable, Hashable {
    case user
    case host
}

struct HostVoiceProfile: Hashable {
    let rate: Float
    let pitch: Float
    let volume: Float
}

struct ConversationMessage: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    let role: SpeakerRole
    let text: String
    let date: Date

    init(id: UUID = UUID(), role: SpeakerRole, text: String, date: Date = Date()) {
        self.id = id
        self.role = role
        self.text = text
        self.date = date
    }
}

struct ConversationSession: Identifiable, Codable, Hashable {
    let id: UUID
    let hostType: HostType
    let startedAt: Date
    var endedAt: Date?
    var messages: [ConversationMessage]

    init(
        id: UUID = UUID(),
        hostType: HostType,
        startedAt: Date = Date(),
        endedAt: Date? = nil,
        messages: [ConversationMessage] = []
    ) {
        self.id = id
        self.hostType = hostType
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.messages = messages
    }
}

struct ConversationResult {
    let score: Int
    let advice: String
    let nextLine: String
}

enum ConversationScorer {
    static func makeResult(messages: [ConversationMessage], hostType: HostType) -> ConversationResult {
        let userMessages = messages.filter { $0.role == .user }
        let wordCount = userMessages.reduce(0) { $0 + $1.text.count }
        let turnBonus = min(userMessages.count * 12, 48)
        let lengthBonus = min(wordCount / 4, 32)
        let score = min(100, 40 + turnBonus + lengthBonus)

        let advice: String
        if userMessages.count <= 1 {
            advice = "一言で終わらず、感想か理由を足すと会話が続きます。"
        } else if wordCount < 40 {
            advice = "短く返せています。次は「なんでそう思ったか」を少し足してみましょう。"
        } else {
            advice = "会話の流れは良いです。相手への質問を混ぜると、もっと自然になります。"
        }

        let nextLine: String
        switch hostType {
        case .gentle:
            nextLine = "それ、もう少し聞いてほしいな。"
        case .strong:
            nextLine = "今の話、俺にだけ続き聞かせて。"
        case .dogLike:
            nextLine = "ねえねえ、それめっちゃ気になる！"
        case .menchika:
            nextLine = "今の言い方、ちょっとかわいかった。"
        case .president:
            nextLine = "その考え方、かなり良いね。"
        }

        return ConversationResult(score: score, advice: advice, nextLine: nextLine)
    }
}
