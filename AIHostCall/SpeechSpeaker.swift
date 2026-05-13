import AVFoundation
import Foundation

@MainActor
final class SpeechSpeaker: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    @Published var rate: Float = 0.42
    @Published var pitch: Float = 0.88
    @Published var volume: Float = 0.96
    @Published private(set) var isSpeaking = false
    @Published private(set) var selectedVoiceName = "日本語音声"

    private let synthesizer = AVSpeechSynthesizer()
    private var selectedVoice: AVSpeechSynthesisVoice?
    private var pendingUtteranceCount = 0

    override init() {
        super.init()
        synthesizer.delegate = self
        refreshBestVoice()
        requestPersonalVoiceIfAvailable()
    }

    func apply(profile: HostVoiceProfile) {
        rate = profile.rate
        pitch = profile.pitch
        volume = profile.volume
    }

    func speak(_ text: String) {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }

        let chunks = Self.speechChunks(from: text)
        pendingUtteranceCount = chunks.count
        isSpeaking = chunks.isEmpty == false

        for (index, chunk) in chunks.enumerated() {
            let utterance = AVSpeechUtterance(string: Self.prepareForSpeech(chunk))
            utterance.voice = selectedVoice ?? AVSpeechSynthesisVoice(language: "ja-JP")
            utterance.rate = adjustedRate(for: index)
            utterance.pitchMultiplier = adjustedPitch(for: index)
            utterance.volume = volume
            utterance.preUtteranceDelay = index == 0 ? 0.02 : 0.06
            utterance.postUtteranceDelay = 0.03
            synthesizer.speak(utterance)
        }
    }

    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
        pendingUtteranceCount = 0
        isSpeaking = false
    }

    private func refreshBestVoice() {
        selectedVoice = Self.bestJapaneseVoice()
        selectedVoiceName = selectedVoice?.name ?? "日本語音声"
    }

    private func requestPersonalVoiceIfAvailable() {
        if #available(iOS 17.0, *) {
            AVSpeechSynthesizer.requestPersonalVoiceAuthorization { [weak self] _ in
                Task { @MainActor in
                    self?.refreshBestVoice()
                }
            }
        }
    }

    private static func bestJapaneseVoice() -> AVSpeechSynthesisVoice? {
        let voices = AVSpeechSynthesisVoice.speechVoices()
            .filter { $0.language == "ja-JP" || $0.language.hasPrefix("ja") }

        let preferredNames = ["Otoya", "Siri", "Hattori", "Kyoko", "O-ren"]
        return voices.sorted { left, right in
            voiceScore(left, preferredNames: preferredNames) > voiceScore(right, preferredNames: preferredNames)
        }
        .first ?? AVSpeechSynthesisVoice(language: "ja-JP")
    }

    private static func voiceScore(_ voice: AVSpeechSynthesisVoice, preferredNames: [String]) -> Int {
        var score = qualityScore(voice.quality) * 100
        if #available(iOS 17.0, *), voice.voiceTraits.contains(.isPersonalVoice) {
            score += 500
        }
        if voice.language == "ja-JP" {
            score += 20
        }
        if preferredNames.contains(where: { voice.name.localizedCaseInsensitiveContains($0) }) {
            score += 10
        }
        return score
    }

    private static func qualityScore(_ quality: AVSpeechSynthesisVoiceQuality) -> Int {
        switch quality {
        case .premium:
            3
        case .enhanced:
            2
        default:
            1
        }
    }

    private func adjustedRate(for index: Int) -> Float {
        let offsets: [Float] = [0, -0.012, 0.008, -0.006]
        return min(0.58, max(0.32, rate + offsets[index % offsets.count]))
    }

    private func adjustedPitch(for index: Int) -> Float {
        let offsets: [Float] = [0, -0.018, 0.012, -0.01]
        return min(1.2, max(0.65, pitch + offsets[index % offsets.count]))
    }

    private static func speechChunks(from text: String) -> [String] {
        let prepared = text
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\n", with: " ")
        guard prepared.isEmpty == false else { return [] }

        var chunks: [String] = []
        var current = ""
        for character in prepared {
            current.append(character)
            if "。！？!?、".contains(character), current.count >= 6 {
                chunks.append(current)
                current = ""
            }
        }
        if current.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false {
            chunks.append(current)
        }
        return chunks.prefix(3).map(String.init)
    }

    private static func prepareForSpeech(_ text: String) -> String {
        text
            .replacingOccurrences(of: "えー", with: "ええ、")
            .replacingOccurrences(of: "えっと", with: "ええと、")
            .replacingOccurrences(of: "！", with: "。")
            .replacingOccurrences(of: "!!", with: "。")
            .replacingOccurrences(of: "？", with: "？ ")
            .replacingOccurrences(of: "。", with: "。 ")
            .replacingOccurrences(of: "、", with: "、 ")
            .replacingOccurrences(of: "\n", with: " ")
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        Task { @MainActor in
            isSpeaking = true
        }
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor in
            pendingUtteranceCount = max(0, pendingUtteranceCount - 1)
            isSpeaking = pendingUtteranceCount > 0
        }
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        Task { @MainActor in
            pendingUtteranceCount = max(0, pendingUtteranceCount - 1)
            isSpeaking = pendingUtteranceCount > 0
        }
    }
}
