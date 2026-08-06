#!/bin/bash
# Build the fork app locally (requires full Xcode) and install it to
# /Applications, replacing any existing VoiceInk.app.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
DERIVED="${DERIVED:-$REPO_ROOT/.fork-build}"

DERIVED="$DERIVED" "$REPO_ROOT/scripts/fork/build-app.sh"
APP="$DERIVED/Build/Products/Release/VoiceInk.app"

osascript -e 'quit app "VoiceInk"' 2>/dev/null || true
sleep 2
pkill -x VoiceInk 2>/dev/null || true

rm -rf /Applications/VoiceInk.app
ditto "$APP" /Applications/VoiceInk.app
xattr -cr /Applications/VoiceInk.app
open /Applications/VoiceInk.app
echo "Installed to /Applications/VoiceInk.app"
