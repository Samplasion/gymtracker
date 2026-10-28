#!/usr/bin/env bash

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

run="build && cleanup && copy"

usage() {
    echo 
    echo "Builds the iOS app"
    echo "Usage: $0 [-ch]"
    echo
    echo "  -c       Only run cleanup"
    echo "  -h       Print this help message"
    echo
    echo "BUILD_NUMBER overrides the build number from pubspec.yaml."
}

while getopts ":ch" opt; do
  case $opt in
    h)
        usage
        exit 0
        ;;
    c)
        run="cleanup"
        ;;
    esac
done

echo 
echo "#############################################################"
echo "##                                                         ##"
echo "##                      Build iOS app                      ##"
echo "##                                                         ##"
echo "#############################################################"
echo 
echo App version: $VER
echo Build number: $BUILD_NUMBER
echo Flavor: $flavor
echo 

if [[ -z "${CI}" ]]; then
  CODESIGN=""
else
  CODESIGN="--no-codesign"
fi

build() {
    echo "📦 Building the iOS app..."
    flutter build ipa --$flavor --build-number=$BUILD_NUMBER --dart-define=BUILD=$BUILD $CODESIGN
}

cleanup() {
    echo "📁 Creating the output directory if it doesn't exist..."
    mkdir -p $CUR/out/ios

    echo "🗑  Removing previous releases..."
    rm -rf $CUR/out/ios/*
    rm -rf $CUR/out/ios/**/*
}

copy() {
    # echo "🌐 Generating payload..."
    # mkdir -p $CUR/out/ios/Payload/Runner.app
    # echo "📑 Copying output files from their directory to our organized directory..."
    # cp -r $CUR/build/ios/archive/Runner.xcarchive/Products/Applications/Runner.app/* $CUR/out/ios/Payload/Runner.app
    # cd $CUR/out/ios
    # zip -r $name-ios-$VER+$BUILD_NUMBER-$flavor.ipa Payload
    # rm -rf Payload
    # cd -
    echo "📑 Copying output files from their directory to our organized directory..."
    cp -r $CUR/build/ios/ipa/*.ipa $CUR/out/ios/$name-ios-$VER+$BUILD_NUMBER-$flavor.ipa || true
}

eval $run
