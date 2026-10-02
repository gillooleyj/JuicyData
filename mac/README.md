# JuicyCloud

A Clippy-style desktop mascot for macOS. Floats above your windows, bobs around, wiggles when clicked, and drops FedRAMP wisdom in a speech bubble.

## Build for yourself

    bash build.sh
    open build/JuicyCloud.app

## Make an installer to share

    bash make_dmg.sh

This creates `build/JuicyCloud-1.0.dmg`: open it and drag JuicyCloud into Applications. Works on Apple Silicon and Intel Macs running macOS 12 or later.

For a signed and notarized installer that opens without warnings, see the signing steps in the chat or set `SIGN_ID` and `NOTARY_PROFILE` as shown at the top of `make_dmg.sh`.

## Using it

- Click the cloud: it shakes and says something.
- Drag it anywhere. Position is remembered.
- Right-click it, or use the ☁️ menu bar icon, for Show/Hide, Size, Chattiness, React to Apps, Speech, and Quit.
- Speech: Off, Only When Clicked, or All Lines. Lines play pre-recorded ElevenLabs clips from `../voice/clips` (bundled by `build.sh`). If a clip is missing, the best male English voice installed is used instead.
- Pronunciation of jargon (POA&M, 3PAO, 20x, and so on): `../voice/config.json` for the recorded clips, and the `pronunciations` list near the top of `main.swift` for the system voice.
