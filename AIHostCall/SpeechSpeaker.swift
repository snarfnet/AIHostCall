import AVFoundation
import Foundation

@MainActor
final class SpeechSpeaker: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    @Published var rate: Float = 0.52
    @Published var pitch: Float = 1.04
    @Published var volume: Float = 0.95
    @Published private(set) var isSpeaking = false
    @Published private(set) var selectedVoiceName = "日本語音声"

    private let synthesizer = AVSpeechSynthesizer()
    private var selectedVoice: AVSpeechSynthesisVoice?

    override init() {
        super.init()
        synthesizer.delegate = self
        selectedVoice = Self.bestJapaneseVoice()
        selectedVoiceName = selectedVoice?.name ?? "日本語音声"
    }

    func apply(profile: HostVoiceProfile) {
        rate = profile.rate
        pitch = profile.pitch
        volume = profile.volume
    }

    func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: Self.prepareForSpeech(text))
        utterance.voice = selectedVoice ?? AVSpeechSynthesisVoice(language: "ja-JP")
        utterance.rate = rate
        utterance.pitchMultiplier = pitch
        utterance.volume = volume
        utterance.preUtteranceDelay = 0.04
        utterance.postUtteranceDelay = 0.08

        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }

        synthesizer.speak(utterance)
    }

    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
        isSpeaking = false
    }

    private static func bestJapaneseVoice() -> AVSpeechSynthesisVoice? {
        let voices = AVSpeechSynthesisVoice.speechVoices()
            .filter { $0.language.hasPrefix("ja") }

        return voices.sorted { left, right in
            qualityScore(left.quality) > qualityScore(right.quality)
        }
        .first ?? AVSpeechSynthesisVoice(language: "ja-JP")
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

    private static func prepareForSpeech(_ text: String) -> String {
        text
            .replacingOccurrences(of: "！", with: "。")
            .replacingOccurrences(of: "？", with: "？ ")
            .replacingOccurrences(of: "。", with: "。 ")
            .replacingOccurrences(of: "、", with: "、 ")
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        Task { @MainActor in
            isSpeaking = true
        }
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor in
            isSpeaking = false
        }
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        Task { @MainActor in
            isSpeaking = false
        }
    }
}
