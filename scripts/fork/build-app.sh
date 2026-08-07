#!/bin/bash
# Build the fork's Release app without an Apple Developer account.
# Same overrides as the Makefile `local` target, but Release configuration and
# (by default) signed with the long-lived self-signed "VoiceInk Fork Signing"
# identity so TCC permissions survive Sparkle updates. Set
# FORK_SIGN_IDENTITY="-" to fall back to ad-hoc signing.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
DERIVED="${DERIVED:-$REPO_ROOT/.fork-build}"
IDENTITY="${FORK_SIGN_IDENTITY:-VoiceInk Fork Signing}"

FRAMEWORK="$HOME/VoiceInk-Dependencies/whisper.cpp/build-apple/whisper.xcframework"
if [ ! -d "$FRAMEWORK" ]; then
    echo "error: whisper.xcframework not found at $FRAMEWORK (run 'make whisper' first)" >&2
    exit 1
fi

cd "$REPO_ROOT"
xcodebuild -project VoiceInk.xcodeproj -scheme VoiceInk -configuration Release \
    -derivedDataPath "$DERIVED" \
    -xcconfig LocalBuild.xcconfig \
    -skipPackagePluginValidation \
    -skipMacroValidation \
    CODE_SIGN_IDENTITY="$IDENTITY" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=YES \
    DEVELOPMENT_TEAM="" \
    CODE_SIGN_ENTITLEMENTS="$REPO_ROOT/VoiceInk/VoiceInk.local.entitlements" \
    SWIFT_ACTIVE_COMPILATION_CONDITIONS='$(inherited) LOCAL_BUILD' \
    build

APP="$DERIVED/Build/Products/Release/VoiceInk.app"
if [ ! -d "$APP" ]; then
    echo "error: build did not produce $APP" >&2
    exit 1
fi
echo "Built: $APP"
