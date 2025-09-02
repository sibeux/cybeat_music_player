#!/bin/bash
flutter build apk --release --split-per-abi --target-platform android-arm,android-arm64,android-x64 --split-debug-info=build/symbols --dart-define=ENV=production