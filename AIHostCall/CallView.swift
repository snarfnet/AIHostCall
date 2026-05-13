import SwiftUI

struct CallView: View {
    let hostType: HostType
    @ObservedObject var store: ConversationStore
    @Binding var path: [AppRoute]

    @StateObject private var recognizer = SpeechRecognizer()
    @StateObject private var speaker = SpeechSpeaker()
    @Environment(\.dismiss) private var dismiss

    @State private var session: ConversationSession
    @State private var hostReply = "今日はどうしたの？声、聞かせて。"
    @State private var isThinking = false
    @State private var silenceTask: Task<Void, Never>?
    @State private var lastSubmittedText = ""
    @State private var isAutoListening = true

    private let aiService = HostAIService()

    init(hostType: HostType, store: ConversationStore, path: Binding<[AppRoute]>) {
        self.hostType = hostType
        self.store = store
        _path = path
        _session = State(initialValue: ConversationSession(hostType: hostType))
    }

    var body: some View {
        ZStack {
            HostBackdrop()

            ScrollView {
                VStack(spacing: 14) {
                    header

                    HostPanel {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("あなた")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(HostCallDesign.softGold)
                            Text(recognizer.transcript.isEmpty ? "そのまま話しかけてください" : recognizer.transcript)
                                .font(.title3.weight(.semibold))
                                .foregroundStyle(recognizer.transcript.isEmpty ? HostCallDesign.subtext : HostCallDesign.text)
                                .frame(maxWidth: .infinity, minHeight: 66, alignment: .topLeading)
                        }
                    }

                    HostPanel {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(hostType.shortName)
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(HostCallDesign.softGold)
                                Spacer()
                                if isThinking {
                                    Text("考え中…")
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(HostCallDesign.gold)
                                } else if speaker.isSpeaking {
                                    Text("再生中")
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(HostCallDesign.gold)
                                }
                            }

                            Text(hostReply)
                                .font(.title3.weight(.semibold))
                                .foregroundStyle(HostCallDesign.text)
                                .frame(maxWidth: .infinity, minHeight: 66, alignment: .topLeading)
                        }
                    }

                    Button {
                        toggleListeningMode()
                    } label: {
                        Image(systemName: micIconName)
                            .font(.system(size: 40, weight: .bold))
                            .foregroundStyle(isAutoListening ? .black : .white)
                            .frame(width: 112, height: 112)
                            .background(isAutoListening ? HostCallDesign.gold : Color.red.opacity(0.88))
                            .clipShape(Circle())
                            .shadow(color: HostCallDesign.gold.opacity(0.42), radius: 24, y: 8)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(isAutoListening ? "自動会話を一時停止" : "自動会話を再開")

                    if let errorMessage = recognizer.errorMessage {
                        Text(errorMessage)
                            .font(.footnote)
                            .foregroundStyle(.red.opacity(0.9))
                            .multilineTextAlignment(.center)
                    } else {
                        Text(statusText)
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(HostCallDesign.subtext)
                    }

                    voiceControls

                    Button {
                        finishCall()
                    } label: {
                        Label("会話終了", systemImage: "phone.down.fill")
                    }
                    .buttonStyle(SecondaryButtonStyle())
                }
                .padding(20)
                .padding(.bottom, 28)
            }
        }
        .task {
            await recognizer.requestAuthorization()
            speaker.apply(profile: hostType.voiceProfile)
            speaker.speak(hostReply)
        }
        .onChange(of: recognizer.transcript) { newValue in
            scheduleAutoReply(for: newValue)
        }
        .onChange(of: speaker.isSpeaking) { speaking in
            if speaking == false {
                restartListeningIfNeeded()
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    private var micIconName: String {
        if isThinking { return "ellipsis" }
        if speaker.isSpeaking { return "speaker.wave.2.fill" }
        if recognizer.isRecording { return "waveform" }
        return isAutoListening ? "mic.fill" : "pause.fill"
    }

    private var statusText: String {
        if isThinking { return "返答を考えています" }
        if speaker.isSpeaking { return "話し終わったら自動で聞きます" }
        if recognizer.isRecording { return "話しかけるだけでOK" }
        return isAutoListening ? "聞き取りを準備中" : "一時停止中"
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(hostType.name)
                    .font(.title2.bold())
                    .foregroundStyle(HostCallDesign.text)
                Text("即答モード")
                    .font(.subheadline)
                    .foregroundStyle(HostCallDesign.subtext)
            }
            Spacer()
            Button {
                speaker.stop()
                recognizer.stopRecording()
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.headline)
                    .foregroundStyle(HostCallDesign.softGold)
                    .frame(width: 42, height: 42)
                    .background(HostCallDesign.panel)
                    .clipShape(Circle())
            }
        }
    }

    private var voiceControls: some View {
        HostPanel {
            VStack(spacing: 8) {
                controlSlider(title: "速さ", value: $speaker.rate, range: 0.36...0.52)
                controlSlider(title: "高さ", value: $speaker.pitch, range: 0.72...1.06)
                controlSlider(title: "音量", value: $speaker.volume, range: 0.3...1.0)
                HStack(spacing: 8) {
                    Text("音声")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(HostCallDesign.subtext)
                        .frame(width: 38, alignment: .leading)
                    Text(speaker.selectedVoiceName)
                        .font(.caption)
                        .foregroundStyle(HostCallDesign.subtext)
                        .lineLimit(1)
                    Spacer(minLength: 0)
                }
            }
        }
    }

    private func controlSlider(title: String, value: Binding<Float>, range: ClosedRange<Float>) -> some View {
        HStack(spacing: 8) {
            Text(title)
                .font(.caption.weight(.bold))
                .foregroundStyle(HostCallDesign.subtext)
                .frame(width: 38, alignment: .leading)
            Slider(value: value, in: range)
                .tint(HostCallDesign.gold)
        }
    }

    private func toggleListeningMode() {
        isAutoListening.toggle()
        if isAutoListening {
            restartListeningIfNeeded()
        } else {
            silenceTask?.cancel()
            recognizer.stopRecording()
        }
    }

    private func scheduleAutoReply(for transcript: String) {
        silenceTask?.cancel()

        let text = transcript.trimmingCharacters(in: .whitespacesAndNewlines)
        guard isAutoListening, recognizer.isRecording, speaker.isSpeaking == false, isThinking == false else { return }
        guard text.count >= 2, text != lastSubmittedText else { return }

        silenceTask = Task {
            try? await Task.sleep(nanoseconds: 1_150_000_000)
            guard Task.isCancelled == false else { return }

            await MainActor.run {
                let current = recognizer.transcript.trimmingCharacters(in: .whitespacesAndNewlines)
                guard current == text, current != lastSubmittedText else { return }
                Task { await sendCurrentTranscript() }
            }
        }
    }

    private func restartListeningIfNeeded() {
        guard isAutoListening, isThinking == false, speaker.isSpeaking == false else { return }
        guard recognizer.isRecording == false else { return }
        recognizer.resetTranscript()
        recognizer.startRecording()
    }

    private func sendCurrentTranscript() async {
        let text = recognizer.transcript.trimmingCharacters(in: .whitespacesAndNewlines)
        guard text.isEmpty == false, text != lastSubmittedText else { return }

        silenceTask?.cancel()
        lastSubmittedText = text
        recognizer.stopRecording()
        let userMessage = ConversationMessage(role: .user, text: text)
        session.messages.append(userMessage)
        isThinking = true

        let reply = await aiService.reply(to: text, hostType: hostType, history: session.messages)
        hostReply = reply
        session.messages.append(ConversationMessage(role: .host, text: reply))
        isThinking = false
        store.save(session)
        speaker.speak(reply)
    }

    private func finishCall() {
        recognizer.stopRecording()
        speaker.stop()
        session.endedAt = Date()
        store.save(session)
        path.append(.result(session))
    }
}
