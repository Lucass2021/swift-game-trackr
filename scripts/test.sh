#!/bin/sh

SIMULATOR_ID=$(xcrun simctl list devices available | grep -m 1 "iPhone" | grep -oE "[0-9A-F-]{36}")

if [ -z "$SIMULATOR_ID" ]; then
    echo "error: no available iPhone simulator"
    exit 1
fi

xcodebuild test \
    -project GameTrackr.xcodeproj \
    -scheme GameTrackr \
    -destination "platform=iOS Simulator,id=$SIMULATOR_ID" \
    -only-testing:GameTrackrTests \
    -quiet
