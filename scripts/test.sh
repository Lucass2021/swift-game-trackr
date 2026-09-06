#!/usr/bin/env bash
set -euo pipefail

SCHEME="GameTrackr"
DESTINATION="${TEST_DESTINATION:-platform=iOS Simulator,name=iPhone 17 Pro}"
LOG="$(mktemp)"

cd "$(dirname "$0")/.."

if ! xcodebuild test \
    -project GameTrackr.xcodeproj \
    -scheme "$SCHEME" \
    -destination "$DESTINATION" \
    -only-testing:GameTrackrTests \
    -quiet >"$LOG" 2>&1; then
    grep -E "error:|failed|\*\* TEST" "$LOG" | head -40
    echo
    echo "Full log: $LOG"
    exit 1
fi

echo "$(grep -c "' passed on" "$LOG") unit tests passed"
