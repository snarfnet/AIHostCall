import Foundation

protocol HostAIProcessing {
    func generateReply(for input: String, hostType: HostType, history: [ConversationMessage]) async throws -> String
}

struct HostAIService {
    private let processor: HostAIProcessing

    init(processor: HostAIProcessing = MockHostAI()) {
        self.processor = processor
    }

    func reply(to input: String, hostType: HostType, history: [ConversationMessage]) async -> String {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else {
            return "今の声、もう一回だけ聞かせて。"
        }

        do {
            return try await processor.generateReply(for: trimmed, hostType: hostType, history: history)
        } catch {
            return "ごめん、少し考えすぎた。今の話、もう少し聞かせて。"
        }
    }

    static func systemPrompt(for hostType: HostType) -> String {
        """
        あなたは日本語で話すAIホストです。
        ユーザーの発言に対して、自然で短く、会話が続く返答をしてください。
        返答は1〜2文。
        説教しない。
        長文にしない。
        少し甘く、相手を気分良くさせる。
        最後に質問を入れると会話が続きやすい。
        ホストタイプ: \(hostType.name)
        口調: \(hostType.promptTone)
        """
    }
}
