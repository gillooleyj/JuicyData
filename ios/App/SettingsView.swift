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
                    LabeledContent("Voice", value: VoicePicker.describe(best))
                    Button("Test Voice") {
                        speaker.speak(spokenText("Hello! I'm the government, and I'm here to help!"))
                    }
                    .disabled(!voiceOn)
                }

                if (best?.quality.rawValue ?? 0) < 3 {
                    Section("Get a better voice") {
                        Text("Open the Settings app, then go to Accessibility > Spoken Content > Voices > English. Download Evan (Premium), or Nathan or Tom (Enhanced). Then close and reopen JuicyCloud. It switches to the new voice automatically.")
                            .font(.footnote)
                    }
                }

                Section("About") {
                    Text("JuicyCloud is an unofficial fan app. It is not affiliated with, endorsed by, or sponsored by GSA, FedRAMP, or any government agency. Quotes are attributed to their speakers as publicly reported.")
                        .font(.footnote)
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
