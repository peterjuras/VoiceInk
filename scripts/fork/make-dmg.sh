#!/bin/bash
# Package the fork app into a plain DMG (no background art, no Developer ID —
# update authenticity comes from the Sparkle EdDSA signature).
set -euo pipefail

APP="${1:?usage: make-dmg.sh <path/to/VoiceInk.app> <path/to/VoiceInk.dmg>}"
DMG="${2:?usage: make-dmg.sh <path/to/VoiceInk.app> <path/to/VoiceInk.dmg>}"

STAGE="$(mktemp -d)"
trap 'rm -rf "$STAGE"' EXIT

ditto "$APP" "$STAGE/VoiceInk.app"
ln -s /Applications "$STAGE/Applications"

rm -f "$DMG"
hdiutil create -volname VoiceInk -srcfolder "$STAGE" -ov -fs APFS -format UDZO "$DMG"
echo "Created: $DMG"
