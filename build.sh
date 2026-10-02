#!/bin/bash
# Builds a universal (Apple Silicon + Intel) JuicyCloud.app into ./build
#
# Optional settings (set before running):
#   SIGN_ID    "Developer ID Application: Your Name (TEAMID)"  (default: ad-hoc "-")
#   VERSION    e.g. 1.0.1                                       (default: 1.0)
#   BUNDLE_ID  e.g. com.cooeytools.juicycloud
set -euo pipefail
cd "$(dirname "$0")"

APP_NAME="JuicyCloud"
VERSION="${VERSION:-1.0}"
BUNDLE_ID="${BUNDLE_ID:-com.cooeytools.juicycloud}"
SIGN_ID="${SIGN_ID:--}"
APP="build/$APP_NAME.app"

if ! command -v swiftc >/dev/null 2>&1; then
  echo "swiftc not found. Install the Command Line Tools first:  xcode-select --install"
  exit 1
fi

rm -rf build
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"

for ARCH in arm64 x86_64; do
  echo "Compiling for $ARCH..."
  swiftc -O -swift-version 5 -target "$ARCH-apple-macos12.0" main.swift \
    -o "build/$APP_NAME-$ARCH" -framework Cocoa -framework QuartzCore
done
lipo -create -output "$APP/Contents/MacOS/$APP_NAME" "build/$APP_NAME-arm64" "build/$APP_NAME-x86_64"
rm -f "build/$APP_NAME-arm64" "build/$APP_NAME-x86_64"

cp mascot.png "$APP/Contents/Resources/"

echo "Making icon..."
ICONSET="build/AppIcon.iconset"
mkdir -p "$ICONSET"
for s in 16 32 128 256 512; do
  sips -z $s $s icon.png --out "$ICONSET/icon_${s}x${s}.png" >/dev/null
  d=$((s * 2))
  sips -z $d $d icon.png --out "$ICONSET/icon_${s}x${s}@2x.png" >/dev/null
done
iconutil -c icns "$ICONSET" -o "$APP/Contents/Resources/AppIcon.icns"
rm -rf "$ICONSET"

cat > "$APP/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleName</key><string>$APP_NAME</string>
  <key>CFBundleDisplayName</key><string>$APP_NAME</string>
  <key>CFBundleIdentifier</key><string>$BUNDLE_ID</string>
  <key>CFBundleExecutable</key><string>$APP_NAME</string>
  <key>CFBundleIconFile</key><string>AppIcon</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleShortVersionString</key><string>$VERSION</string>
  <key>CFBundleVersion</key><string>$VERSION</string>
  <key>LSMinimumSystemVersion</key><string>12.0</string>
  <key>LSUIElement</key><true/>
  <key>NSHighResolutionCapable</key><true/>
</dict>
</plist>
PLIST

echo "Signing..."
if [ "$SIGN_ID" = "-" ]; then
  codesign --force --sign - "$APP"
else
  codesign --force --options runtime --timestamp --sign "$SIGN_ID" "$APP"
fi

echo ""
echo "Built $APP (version $VERSION, universal)"
