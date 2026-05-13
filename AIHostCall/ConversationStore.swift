import Foundation

@MainActor
final class ConversationStore: ObservableObject {
    @Published private(set) var sessions: [ConversationSession] = []

    private let key = "ai_host_call_sessions_v1"

    init() {
        load()
    }

    func save(_ session: ConversationSession) {
        sessions.removeAll { $0.id == session.id }
        sessions.insert(session, at: 0)
        persist()
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key) else {
            sessions = []
            return
        }

        do {
            sessions = try JSONDecoder().decode([ConversationSession].self, from: data)
        } catch {
            sessions = []
        }
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(sessions) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }
}
