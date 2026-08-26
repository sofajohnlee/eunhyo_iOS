#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
HARI="$ROOT_DIR/eunhyo_iOS/Hari"
ENGINE="$ROOT_DIR/eunhyo_iOS/AIMLAssetLoader.swift"

[ -d "$HARI/aiml" ] || { echo "Missing Hari AIML assets"; exit 1; }
[ -d "$HARI/config" ] || { echo "Missing Hari config assets"; exit 1; }

AIML_COUNT=$(find "$HARI/aiml" -type f -name '*.aiml' | wc -l | tr -d ' ')
CONFIG_COUNT=$(find "$HARI/config" -type f | wc -l | tr -d ' ')
[ "$AIML_COUNT" -ge 12 ] || { echo "Expected at least 12 AIML files, found $AIML_COUNT"; exit 1; }
[ "$CONFIG_COUNT" -ge 8 ] || { echo "Expected at least 8 config files, found $CONFIG_COUNT"; exit 1; }

grep -q '<that>' "$HARI/aiml/that.aiml"
grep -q '<srai>' "$HARI/aiml/that.aiml"
grep -q '<condition' "$HARI/aiml/dialog.aiml"
grep -q 'thatPattern' "$ENGINE"
grep -q 'thatstar' "$ENGINE"
grep -q 'replacePairedTag(in: text, tag: "srai")' "$ENGINE"
grep -q 'replacePairedTag(in: text, tag: "condition")' "$ENGINE"

echo "AIML parity validation passed: $AIML_COUNT AIML files, $CONFIG_COUNT config files"
