#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TMP_DIR="${TMPDIR:-/tmp}/eunhyo2-android-assets"
SOURCE_REPO="https://github.com/sofajohnlee/eunhyo2.git"
DEST_HARI="$ROOT_DIR/eunhyo_iOS/Hari"

rm -rf "$TMP_DIR"
git clone --depth 1 "$SOURCE_REPO" "$TMP_DIR"

rm -rf "$DEST_HARI"
mkdir -p "$DEST_HARI"
cp -R "$TMP_DIR/app/src/main/assets/Hari/." "$DEST_HARI/"

echo "Synced Android Hari assets to: $DEST_HARI"
echo "AIML files: $(find "$DEST_HARI/aiml" -type f -name '*.aiml' 2>/dev/null | wc -l | tr -d ' ')"
echo "Config files: $(find "$DEST_HARI/config" -type f 2>/dev/null | wc -l | tr -d ' ')"
