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

## GSA machines

To just use JuicyCloud, you don't need Homebrew or anything else: download the installer above. These steps are only for building from source on a GSA-issued Mac.

GSA-managed Macs may not give you admin rights, and the GSA network may block some downloads. Installing the Command Line Tools, Xcode, or Homebrew can need either one. If a step fails for those reasons, ask GSA IT to install or approve the tool. Don't try to get around agency controls (no VPNs, proxies, or alternate download mirrors). Check GSA's software policy before installing anything; see also the device note in the [Mac install guide](docs/MAC-INSTALL.md).

1. Command Line Tools (Mac app and iPhone app). Prints a path if they're installed; otherwise starts the installer:

   ```
   xcode-select -p || xcode-select --install
   ```

2. Homebrew (iPhone app only). Check whether it's installed:

   ```
   brew --version
   ```

   If that says `command not found`, the official install command from [brew.sh](https://brew.sh) is below. It asks for an admin password; without one, ask GSA IT to install Homebrew for you (Homebrew also publishes a `.pkg` installer for managed Macs).

   ```
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

   When it finishes, run the "Next steps" commands it prints so `brew` is on your PATH.

3. Packages (iPhone app only):

   ```
   brew install xcodegen         # generates the Xcode project from ios/project.yml
   ```

The Mac app needs no Homebrew packages. `mac/build.sh` uses only tools that come with macOS and the Command Line Tools (`swiftc`, `python3`, `sips`, `iconutil`, `codesign`). The iPhone app also needs full Xcode from the Mac App Store.

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
