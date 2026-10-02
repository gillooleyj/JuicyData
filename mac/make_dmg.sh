#!/bin/bash
# Builds JuicyCloud and packages it as a drag-to-Applications .dmg installer.
#
# Free (unsigned) build:
#   bash make_dmg.sh
#
# Signed + notarized build (Apple Developer Program required):
#   SIGN_ID="Developer ID Application: Your Name (TEAMID)" \
#   NOTARY_PROFILE="juicy-notary" \
#   bash make_dmg.sh
set -euo pipefail
cd "$(dirname "$0")"

APP_NAME="JuicyCloud"
export VERSION="${VERSION:-1.0}"
export BUNDLE_ID="${BUNDLE_ID:-com.cooeytools.juicycloud}"
export SIGN_ID="${SIGN_ID:--}"
NOTARY_PROFILE="${NOTARY_PROFILE:-}"

bash build.sh

APP="build/$APP_NAME.app"
STAGE="build/dmg"
DMG="build/$APP_NAME-$VERSION.dmg"

echo "Packaging disk image..."
rm -rf "$STAGE" "$DMG"
mkdir -p "$STAGE"
cp -R "$APP" "$STAGE/"
ln -s /Applications "$STAGE/Applications"
hdiutil create -volname "$APP_NAME" -srcfolder "$STAGE" -ov -format UDZO "$DMG" >/dev/null
rm -rf "$STAGE"

if [ "$SIGN_ID" != "-" ]; then
  echo "Signing disk image..."
  codesign --force --timestamp --sign "$SIGN_ID" "$DMG"
fi

if [ -n "$NOTARY_PROFILE" ]; then
  if [ "$SIGN_ID" = "-" ]; then
    echo "Notarization needs a Developer ID signature. Set SIGN_ID and try again."
    exit 1
  fi
  echo "Sending to Apple for notarization (usually a few minutes)..."
  xcrun notarytool submit "$DMG" --keychain-profile "$NOTARY_PROFILE" --wait
  xcrun stapler staple "$DMG"
  echo ""
  echo "Gatekeeper check:"
  spctl -a -t open --context context:primary-signature -v "$DMG" || true
fi

echo ""
echo "Installer ready: $DMG"
if [ "$SIGN_ID" = "-" ]; then
  echo "Note: this build is unsigned. Other Macs will show a security warning on first launch."
fi
open build
