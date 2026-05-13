import Foundation

struct GemmaProcessor: HostAIProcessing {
    func generateReply(for input: String, hostType: HostType, history: [ConversationMessage]) async throws -> String {
        // TODO: Google AI Edge / MediaPipe LLM Inference APIを接続する。
        // HostAIService.systemPrompt(for:)をsystem promptとして渡し、返答は1〜2文に丸める。
        throw GemmaProcessorError.notConnected
    }
}

enum GemmaProcessorError: Error {
    case notConnected
}
