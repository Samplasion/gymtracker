#!/bin/bash

set -e

# Set up environment
name="GymBro"
flavor="release"
BUILD=$(git rev-parse HEAD | cut -c1-7)
CUR=$(pwd)
VERSION=$(awk '/^version: / { print $2; exit }' "$CUR/pubspec.yaml")
VER=${VERSION%%+*}
# Use pubspec's build number unless explicitly overridden by the caller.
if [[ -z "${BUILD_NUMBER+x}" && "$VERSION" != *+* ]]; then
    echo "Missing build number: add +<number> to pubspec.yaml or set BUILD_NUMBER." >&2
    exit 1
fi
BUILD_NUMBER=${BUILD_NUMBER-${VERSION#*+}}
if [[ ! "$BUILD_NUMBER" =~ ^[0-9]+$ ]]; then
    echo "BUILD_NUMBER must be a non-negative integer." >&2
    exit 1
fi

# run="build && cleanup && copy"
run="usage"
artifact=""

usage() {
    echo 
    echo "Builds the Android APK and App Bundle"
    echo "Usage: $0 [-abch]"
    echo
    echo "  -a       Builds the APK"
    echo "  -b       Builds the App Bundle"
    echo "  -c       Only run cleanup"
    echo "  -d       Build debug app"
    echo "  -h       Print this help message"
    echo
    echo "BUILD_NUMBER overrides the build number from pubspec.yaml."
}

while getopts ":abcdh" opt; do
  case $opt in
    a)
        artifact="apk"
        run="_build_apk && cleanup && copy"
        ;;
    b)
        artifact="appbundle"
        run="_build_appbundle && cleanup && copy"
        ;;
    h)
        usage
        exit 0
        ;;
    c)
        run="cleanup"
        ;;
    d)
        flavor="debug"
        ;;
    esac
done

echo 
echo "#############################################################"
echo "##                                                         ##"
echo "##                    Build Android APK                    ##"
echo "##                 and Android App Bundle                  ##"
echo "##                                                         ##"
echo "#############################################################"
echo 
echo App version: $VER
echo Build number: $BUILD_NUMBER
echo Flavor: $flavor
echo 

_build_appbundle() {
    echo "📦 Building the bundle..."
    flutter build appbundle --$flavor --build-number $BUILD_NUMBER --dart-define=BUILD=$BUILD
}

_build_apk() {
    echo "📦 Building the APK..."
    flutter build apk --$flavor --build-number $BUILD_NUMBER --dart-define=BUILD=$BUILD
}

build() {
    _build_appbundle & _build_apk
    wait
}

cleanup() {
    echo "📁 Creating the output directory if it doesn't exist..."
    mkdir -p $CUR/out/android

    echo "🗑 Removing previous releases..."
    rm -rf $CUR/out/android/*
    rm -rf $CUR/out/android/**/*
}

copy() {
    echo "📑 Copying output files from their directory to our organized directory..."
    case "$artifact" in
        apk)
            cp "$CUR/build/app/outputs/flutter-apk/app-$flavor.apk" "$CUR/out/android/$name-android-$VER+$BUILD_NUMBER-$flavor.apk"
            ;;
        appbundle)
            cp "$CUR/build/app/outputs/bundle/$flavor/app-$flavor.aab" "$CUR/out/android/$name-androidbundle-$VER+$BUILD_NUMBER-$flavor.aab"
            ;;
    esac
}

eval $run