#!/bin/bash
set -e

# If flutter is already in PATH (local dev or pre-installed env), use it directly
if command -v flutter >/dev/null 2>&1; then
  echo "==> Using system Flutter SDK: $(which flutter)"
else
  FLUTTER_DIR="flutter"
  FLUTTER_CHANNEL="stable"

  if [ ! -d "$FLUTTER_DIR" ]; then
    echo "==> Cloning Flutter SDK ($FLUTTER_CHANNEL)..."
    git clone https://github.com/flutter/flutter.git -b $FLUTTER_CHANNEL --depth 1
  else
    echo "==> Using cached Flutter SDK directory"
  fi

  export PATH="$PATH:`pwd`/$FLUTTER_DIR/bin"
fi

echo "==> Flutter Version:"
flutter --version

echo "==> Fetching dependencies..."
flutter pub get

echo "==> Building Flutter Web (Release)..."
flutter build web --release

echo "==> Build completed successfully! Output: build/web"
