import SwiftUI
import AVFoundation

struct SettingsView: View {
    @ObservedObject var speaker: Speaker
    @AppStorage("voiceOn") private var voiceOn = true
    @Environment(\.dismiss) private var dismiss

    private let best = VoicePicker.best()

    var body: some View {
        NavigationStack {
            Form {
                Section("Voice") {
                    Toggle("Speak when tapped", isOn: $voiceOn)
                    LabeledContent("Voice", value: Clips.voiceName.map { "\($0) (ElevenLabs AI voice)" }
                                                   ?? VoicePicker.describe(best))
                    Button("Test Voice") {
                        speaker.speak("Hello! I'm the government, and I'm here to help!")
                    }
                    .disabled(!voiceOn)
                }

                // Only needed when the recorded clips are missing from the build.
                if Clips.voiceName == nil && (best?.quality.rawValue ?? 0) < 3 {
                    Section("Get a better voice") {
                        Text("Open the Settings app, then go to Accessibility > Spoken Content > Voices > English. Download Evan (Premium), or Nathan or Tom (Enhanced). Then close and reopen JuicyCloud. It switches to the new voice automatically.")
                            .font(.footnote)
                    }
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
