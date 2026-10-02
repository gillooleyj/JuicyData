# JuicyCloud

A Clippy-style cloud mascot that serves up FedRAMP 20x humor. Available as a floating desktop buddy for macOS and as an iPhone app with Home Screen and Lock Screen widgets.

## Download

**Mac:** [Download the latest JuicyCloud installer](https://github.com/gillooleyj/JuicyData/releases/latest). Under **Assets**, click the `JuicyCloud-x.y.dmg` file, open it, and drag JuicyCloud into Applications. It's signed and notarized by Apple, and runs on Apple Silicon and Intel Macs with macOS 12 or later. See the [Mac install and setup guide](docs/MAC-INSTALL.md) for details.

**iPhone:** not in the App Store yet. Build it from source with Xcode (see [Build the iPhone app](#build-the-iphone-app)).

## What's here

| Folder | Contents |
|---|---|
| `mac/` | macOS app (Swift, AppKit). Builds a universal `.app` and a signed, notarized `.dmg` installer. |
| `ios/` | iPhone app and widget (SwiftUI, WidgetKit). Xcode project is generated with XcodeGen. |
| `docs/` | End-user install and setup guide for the Mac app. |

## Features

- Floats above your windows (Mac), bobs, wiggles when clicked, and talks in a speech bubble
- About 45 lines on 20x, the Rev5 transition, CR26, KSIs, and life in compliance
- Optional voice: every line is pre-recorded with an ElevenLabs AI voice
- Mac: reacts when you switch into Excel, Word, Teams, and more
- iPhone: tap-to-talk app, share button, and widgets that show a new line every hour

## Build the Mac app

Requires the Xcode Command Line Tools (`xcode-select --install`).

```
cd mac
bash build.sh                 # build and run locally: open build/JuicyCloud.app
bash make_dmg.sh              # unsigned .dmg installer
```

For a signed and notarized installer, see the comments at the top of `mac/make_dmg.sh`.

## Build the iPhone app

Requires Xcode and XcodeGen (`brew install xcodegen`).

```
cd ios
bash setup.sh YOUR_TEAM_ID    # generates and opens the Xcode project
```

## Customize

- Lines: `mac/main.swift` (`defaultLines`) and `ios/Shared/Lines.swift` (`Lines.all`). Keep the two lists identical. Lines are fixed in the app, not user-editable, so every line has a recording.
- Voice clips: after changing lines, run `python3 voice/generate.py` to re-record them (see below)
- Pronunciation of jargon: `voice/config.json` for the recorded voice, and the `pronunciations` list in the Swift files for the system voice
- Art: replace `mac/mascot.png` and `ios/Shared/Assets.xcassets/Mascot.imageset/mascot.png` with a transparent PNG

## Voice

The built-in lines are pre-recorded with [ElevenLabs](https://elevenlabs.io) and bundled in `voice/clips/`, so everyone hears the same voice with no downloads. Each clip is named by a hash of its line. A line without a clip (one you just added or edited) falls back to the system voice until you re-record.

To re-record after changing lines, voice, or pronunciations:

1. Store your ElevenLabs API key in the Keychain once: `security add-generic-password -a "$USER" -s elevenlabs-api-key -w`
2. `python3 voice/generate.py --list` shows what will be recorded and how many characters it costs.
3. `python3 voice/generate.py` records only the missing or changed lines.

Voice, model, and pronunciations are set in `voice/config.json`.

## License

Code is released under the [MIT License](LICENSE).
