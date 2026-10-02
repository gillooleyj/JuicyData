#!/bin/bash
# Usage: bash setup.sh YOUR_TEAM_ID
# Writes your Team ID into the project, generates the Xcode project, and opens it.
set -euo pipefail
cd "$(dirname "$0")"

TEAM="${1:-}"
if [ -z "$TEAM" ]; then
  echo "Usage: bash setup.sh YOUR_TEAM_ID"
  exit 1
fi
if ! command -v xcodegen >/dev/null 2>&1; then
  echo "XcodeGen not found. Install it with:  brew install xcodegen"
  exit 1
fi

sed -i '' "s/DEVELOPMENT_TEAM: .*/DEVELOPMENT_TEAM: $TEAM/" project.yml
xcodegen generate
open JuicyCloud.xcodeproj
