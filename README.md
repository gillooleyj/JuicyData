# JuicyCloud

A Clippy-style cloud mascot that serves up FedRAMP 20x humor. Available as a floating desktop buddy for macOS and as an iPhone app with Home Screen and Lock Screen widgets.

> **Unofficial fan project.** JuicyCloud is not affiliated with, endorsed by, or sponsored by GSA, FedRAMP, or any government agency. Quotes are attributed to their speakers as publicly reported.

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
- Optional voice that automatically uses the best male English voice installed
- Mac: reacts when you switch into Excel, Word, Teams, and more; customizable lines file
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

- Lines: `mac/main.swift` (`defaultLines`) and `ios/Shared/Lines.swift`
- Pronunciation of jargon for the voice: the `pronunciations` list in the same files
- Art: replace `mac/mascot.png` and `ios/Shared/Assets.xcassets/Mascot.imageset/mascot.png` with a transparent PNG

## License

Code is released under the [MIT License](LICENSE).
