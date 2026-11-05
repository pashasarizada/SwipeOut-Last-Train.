#!/usr/bin/env bash
# Single quality gate: formatting, static analysis, tests. Fails on first error.
set -euo pipefail
cd "$(dirname "$0")/.."

echo "==> dart format"
dart format --output=none --set-exit-if-changed lib test tool
echo "==> flutter analyze"
flutter analyze
echo "==> flutter test"
flutter test
