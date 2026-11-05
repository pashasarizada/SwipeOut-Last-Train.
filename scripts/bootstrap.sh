#!/usr/bin/env bash
# Prepares a fresh (e.g. cloud) checkout: checks the toolchain, fetches
# packages and runs the quality gate. Installs nothing by itself.
set -euo pipefail
cd "$(dirname "$0")/.."

if ! command -v flutter >/dev/null 2>&1; then
  cat >&2 <<'MSG'
BLOCKED: Flutter SDK bulunamadı.
Kurulum (stable kanal, Flutter 3.32.x / Dart 3.8.x):
  git clone https://github.com/flutter/flutter.git -b stable "$HOME/flutter"
  export PATH="$HOME/flutter/bin:$PATH"
  flutter --version
Sonra bu script'i yeniden çalıştırın.
MSG
  exit 1
fi

flutter --version
flutter pub get
scripts/check.sh
