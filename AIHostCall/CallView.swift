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

            VStack(spacing: 18) {
                header

                HostPanel {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("あなた")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(HostCallDesign.softGold)
                        Text(recognizer.transcript.isEmpty ? "マイクを押して話してください" : recognizer.transcript)
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(recognizer.transcript.isEmpty ? HostCallDesign.subtext : HostCallDesign.text)
                            .frame(maxWidth: .infinity, minHeight: 74, alignment: .topLeading)
                    }
                }

                HostPanel {
                    VStack(alignment: .leading, spacing: 10) {
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
                            .frame(maxWidth: .infinity, minHeight: 74, alignment: .topLeading)
                    }
                }

                Spacer(minLength: 8)

                Button {
                    toggleRecording()
                } label: {
                    Image(systemName: recognizer.isRecording ? "stop.fill" : "mic.fill")
                        .font(.system(size: 44, weight: .bold))
                        .foregroundStyle(recognizer.isRecording ? .white : .black)
                        .frame(width: 126, height: 126)
                        .background(recognizer.isRecording ? Color.red.opacity(0.88) : HostCallDesign.gold)
                        .clipShape(Circle())
                        .shadow(color: HostCallDesign.gold.opacity(0.42), radius: 28, y: 10)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(recognizer.isRecording ? "録音停止" : "録音開始")

                if let errorMessage = recognizer.errorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(.red.opacity(0.9))
                        .multilineTextAlignment(.center)
                } else {
                    Text(recognizer.isRecording ? "話し終わったら停止" : "押して話す")
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
        }
        .task {
            await recognizer.requestAuthorization()
            speaker.apply(profile: hostType.voiceProfile)
            speaker.speak(hostReply)
        }
        .navigationBarBackButtonHidden(true)
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
            VStack(spacing: 12) {
                controlSlider(title: "速さ", value: $speaker.rate, range: 0.42...0.62)
                controlSlider(title: "高さ", value: $speaker.pitch, range: 0.85...1.25)
                controlSlider(title: "音量", value: $speaker.volume, range: 0.3...1.0)
                HStack {
                    Text("音声")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(HostCallDesign.subtext)
                        .frame(width: 42, alignment: .leading)
                    Text(speaker.selectedVoiceName)
                        .font(.caption)
                        .foregroundStyle(HostCallDesign.subtext)
                        .lineLimit(1)
                    Spacer()
                }
            }
        }
    }

    private func controlSlider(title: String, value: Binding<Float>, range: ClosedRange<Float>) -> some View {
        HStack {
            Text(title)
                .font(.caption.weight(.bold))
                .foregroundStyle(HostCallDesign.subtext)
                .frame(width: 42, alignment: .leading)
            Slider(value: value, in: range)
                .tint(HostCallDesign.gold)
        }
    }

    private func toggleRecording() {
        if recognizer.isRecording {
            recognizer.stopRecording()
            Task { await sendCurrentTranscript() }
        } else {
            speaker.stop()
            recognizer.startRecording()
        }
    }

    private func sendCurrentTranscript() async {
        let text = recognizer.transcript.trimmingCharacters(in: .whitespacesAndNewlines)
        guard text.isEmpty == false else { return }

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
