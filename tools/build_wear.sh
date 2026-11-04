#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
variant="Release"
if [[ "${1:-}" == "--debug" ]]; then variant="Debug"; fi
version=$(awk '/^version: / { print $2; exit }' pubspec.yaml)
number=${BUILD_NUMBER:-${version#*+}}
if [[ ! "$number" =~ ^[0-9]+$ ]]; then echo 'Missing numeric build number' >&2; exit 1; fi
version="${version%%+*}+$number"
# Flutter refreshes local.properties for both Android application modules.
flutter_bin=${FLUTTER_BIN:-.fvm/flutter_sdk/bin/flutter}
if [[ ! -x "$flutter_bin" ]]; then flutter_bin=flutter; fi
if [[ "$variant" == Debug ]]; then
    "$flutter_bin" build apk --debug --build-number "$number"
else
    "$flutter_bin" build apk --release --build-number "$number"
    "$flutter_bin" build appbundle --release --build-number "$number"
fi
(
    cd android
    ./gradlew :wearable-core:testDebugUnitTest :wear:testDebugUnitTest ":wear:lint$variant" ":wear:assemble$variant" ":wear:bundle$variant"
)
mkdir -p out/android
lower=$(echo "$variant" | tr '[:upper:]' '[:lower:]')
cp "build/app/outputs/flutter-apk/app-$lower.apk" "out/android/GymBro-android-${version}-$lower.apk"
cp "build/wear/outputs/apk/$lower/wear-$lower.apk" "out/android/GymBro-wear-${version}-$lower.apk"
cp "build/wear/outputs/bundle/$lower/wear-$lower.aab" "out/android/GymBro-wear-${version}-$lower.aab"
if [[ "$variant" == Release ]]; then cp build/app/outputs/bundle/release/app-release.aab "out/android/GymBro-android-${version}-release.aab"; fi
