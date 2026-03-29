#!/bin/bash
set -e

echo "=== Pushing metadata to iOS App Store ==="
bundle exec fastlane ios metadata

echo ""
echo "=== Pushing metadata to Mac App Store ==="
bundle exec fastlane mac metadata

echo ""
echo "Done. Metadata pushed to both iOS and Mac App Store."
