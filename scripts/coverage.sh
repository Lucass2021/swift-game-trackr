#!/usr/bin/env bash
set -euo pipefail

SCHEME="GameTrackr"
DESTINATION="${COVERAGE_DESTINATION:-platform=iOS Simulator,name=iPhone 17 Pro}"
RESULT_BUNDLE="$(mktemp -d)/GameTrackr.xcresult"

cd "$(dirname "$0")/.."

xcodebuild test \
    -project GameTrackr.xcodeproj \
    -scheme "$SCHEME" \
    -destination "$DESTINATION" \
    -only-testing:GameTrackrTests \
    -enableCodeCoverage YES \
    -resultBundlePath "$RESULT_BUNDLE" \
    -quiet

echo
echo "── Coverage by target ──────────────────────────────────────────"
xcrun xccov view --report --only-targets "$RESULT_BUNDLE"

echo
echo "── Core and ViewModels ─────────────────────────────────────────"
xcrun xccov view --report --files-for-target GameTrackr.app "$RESULT_BUNDLE" \
    | grep -E "Core/|ViewModel|EditProfileModel" \
    | sed 's|.*/GameTrackr/||' \
    | sort
