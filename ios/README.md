# JuicyCloud for iPhone

SwiftUI app plus a Home Screen and Lock Screen widget. iOS 17 or later.

- App: tap the cloud for a new line. It wiggles, speaks (optional), and you can share the line.
- Widget: Small, Medium, Large, and Lock Screen sizes. Shows a new line every hour.
- Lines and pronunciations live in `Shared/Lines.swift`. Recorded voice clips come from `../voice/clips` (see the main README).
- The FedRAMP logo is used with permission. Keep that permission on file: App Review may ask for it.

## Setup

1. Install Xcode from the Mac App Store and open it once.
2. Install XcodeGen: `brew install xcodegen`
3. `bash setup.sh YOUR_TEAM_ID`
4. In Xcode, pick an iPhone simulator at the top and press Run.

If you change `project.yml` or add files, run `xcodegen generate` again.
