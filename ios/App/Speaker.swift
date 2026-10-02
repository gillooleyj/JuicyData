import AVFoundation
import Combine
import CryptoKit

/// Pre-rendered ElevenLabs clips for the built-in lines (see voice/generate.py),
/// looked up by a hash of the exact bubble text.
enum Clips {
    static func key(_ text: String) -> String {
        SHA256.hash(data: Data(text.utf8)).prefix(8).map { String(format: "%02x", $0) }.joined()
    }

    static func url(for text: String) -> URL? {
        Bundle.main.url(forResource: key(text), withExtension: "mp3", subdirectory: "clips")
    }

    /// The voice the clips were made with, e.g. "Eric".
    static let voiceName: String? = {
        guard let url = Bundle.main.url(forResource: "manifest", withExtension: "json", subdirectory: "clips"),
              let data = try? Data(contentsOf: url),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return nil }
        return json["voice_name"] as? String
    }()
}

/// Speech with a published "is talking" flag for the animation.
final class Speaker: NSObject, ObservableObject, AVSpeechSynthesizerDelegate, AVAudioPlayerDelegate {
    @Published var isSpeaking = false

    private let synth = AVSpeechSynthesizer()
    private var current: AVSpeechUtterance?
    private var player: AVAudioPlayer?

    override init() {
        super.init()
        synth.delegate = self
    }

    /// Speaks a bubble line: its bundled clip if there is one, otherwise the system voice.
    func speak(_ text: String) {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
        try? session.setActive(true)

        stop()
        if let url = Clips.url(for: text), let p = try? AVAudioPlayer(contentsOf: url) {
            p.delegate = self
            player = p
            if p.play() {
                isSpeaking = true
                return
            }
            player = nil
        }
        let u = AVSpeechUtterance(string: spokenText(text))
        u.voice = VoicePicker.best() ?? AVSpeechSynthesisVoice(language: "en-US")
        u.rate = AVSpeechUtteranceDefaultSpeechRate
        u.pitchMultiplier = 1.0
        current = u
        synth.speak(u)
    }

    func stop() {
        current = nil
        synth.stopSpeaking(at: .immediate)
        player?.delegate = nil
        player?.stop()
        player = nil
        isSpeaking = false
    }

    private func finished(_ u: AVSpeechUtterance) {
        DispatchQueue.main.async {
            guard u === self.current else { return }
            self.isSpeaking = false
            try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        }
    }

    func audioPlayerDidFinishPlaying(_ p: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async {
            guard p === self.player else { return }
            self.player = nil
            self.isSpeaking = false
            try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        }
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            if utterance === self.current { self.isSpeaking = true }
        }
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        finished(utterance)
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        finished(utterance)
    }

}

/// Picks the best-sounding male English voice installed, so users never have to choose.
enum VoicePicker {
    /// Novelty and retro voices to skip.
    static let skip: Set<String> = [
        "Albert", "Bad News", "Bahh", "Bells", "Boing", "Bubbles", "Cellos", "Fred", "Good News",
        "Jester", "Junior", "Organ", "Ralph", "Superstar", "Trinoids", "Whisper", "Wobble", "Zarvox",
        "Eddy", "Grandpa", "Reed", "Rocko",
    ]
    /// Tiebreakers among voices of equal quality, best first.
    static let preferred = ["Evan", "Nathan", "Alex", "Tom", "Aaron", "Daniel", "Oliver", "Arthur", "Lee"]

    static func baseName(_ v: AVSpeechSynthesisVoice) -> String {
        v.name.components(separatedBy: " (").first ?? v.name
    }

    static func best() -> AVSpeechSynthesisVoice? {
        let candidates = AVSpeechSynthesisVoice.speechVoices().filter {
            $0.language.hasPrefix("en") && !skip.contains(baseName($0)) && !$0.identifier.contains("eloquence")
        }
        func score(_ v: AVSpeechSynthesisVoice) -> (Int, Int, Int, Int) {
            let male = v.gender == .male ? 1 : 0
            let us = v.language == "en-US" ? 1 : 0
            let rank = preferred.firstIndex(of: baseName(v)).map { 100 - $0 } ?? 0
            return (male, v.quality.rawValue, us, rank)
        }
        return candidates.max { score($0) < score($1) }
    }

    /// e.g. "Evan (Premium)"
    static func describe(_ v: AVSpeechSynthesisVoice?) -> String {
        guard let v = v else { return "System default" }
        switch v.quality.rawValue {
        case 3...: return "\(baseName(v)) (Premium)"
        case 2: return "\(baseName(v)) (Enhanced)"
        default: return "\(baseName(v)) (Basic)"
        }
    }
}
