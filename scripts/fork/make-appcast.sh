#!/bin/bash
# Generate a single-item Sparkle appcast for a fork release.
# Requires: SPARKLE_BIN (dir containing sign_update) and
# SPARKLE_ED_PRIVATE_KEY (base64 EdDSA private key, passed via stdin to sign_update).
set -euo pipefail

APP="${1:?usage: make-appcast.sh <app> <dmg> <tag> <out.xml>}"
DMG="${2:?usage: make-appcast.sh <app> <dmg> <tag> <out.xml>}"
TAG="${3:?usage: make-appcast.sh <app> <dmg> <tag> <out.xml>}"
OUT="${4:?usage: make-appcast.sh <app> <dmg> <tag> <out.xml>}"
: "${SPARKLE_BIN:?SPARKLE_BIN must point to the Sparkle tools bin directory}"
: "${SPARKLE_ED_PRIVATE_KEY:?SPARKLE_ED_PRIVATE_KEY must hold the base64 EdDSA private key}"

PLIST="$APP/Contents/Info.plist"
SHORT_VERSION=$(plutil -extract CFBundleShortVersionString raw "$PLIST")
BUILD_VERSION=$(plutil -extract CFBundleVersion raw "$PLIST")
MIN_SYSTEM=$(plutil -extract LSMinimumSystemVersion raw "$PLIST")

SIG_LINE=$(printf '%s' "$SPARKLE_ED_PRIVATE_KEY" | "$SPARKLE_BIN/sign_update" --ed-key-file - "$DMG")
ED_SIGNATURE=$(sed -n 's/.*sparkle:edSignature="\([^"]*\)".*/\1/p' <<<"$SIG_LINE")
LENGTH=$(sed -n 's/.*length="\([^"]*\)".*/\1/p' <<<"$SIG_LINE")
if [ -z "$ED_SIGNATURE" ] || [ -z "$LENGTH" ]; then
    echo "error: could not parse sign_update output: $SIG_LINE" >&2
    exit 1
fi

URL="https://github.com/peterjuras/VoiceInk/releases/download/$TAG/VoiceInk.dmg"
PUB_DATE=$(LC_ALL=C date -u +"%a, %d %b %Y %H:%M:%S +0000")

cat > "$OUT" <<EOF
<?xml version="1.0" encoding="utf-8"?>
<rss version="2.0" xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle">
    <channel>
        <title>VoiceInk (peterjuras fork)</title>
        <item>
            <title>$SHORT_VERSION</title>
            <pubDate>$PUB_DATE</pubDate>
            <sparkle:version>$BUILD_VERSION</sparkle:version>
            <sparkle:shortVersionString>$SHORT_VERSION</sparkle:shortVersionString>
            <sparkle:minimumSystemVersion>$MIN_SYSTEM</sparkle:minimumSystemVersion>
            <description><![CDATA[
                <p>Fork build of VoiceInk $TAG. See the <a href="https://github.com/Beingpax/VoiceInk/releases/tag/$TAG">upstream release notes</a>.</p>
            ]]></description>
            <enclosure url="$URL" length="$LENGTH" type="application/octet-stream" sparkle:edSignature="$ED_SIGNATURE"/>
        </item>
    </channel>
</rss>
EOF

xmllint --noout "$OUT"
echo "Wrote: $OUT"
