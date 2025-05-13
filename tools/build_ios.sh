#!/usr/bin/env bash

set -e

# Set up environment
name="GymBro"
flavor="release"
NOW=$(date +"%s")
BUILD=$(git rev-parse HEAD | cut -c1-7)
CUR=$(pwd)
VER=$(grep "version: " $CUR/pubspec.yaml | sed 's/version: //')

run="build && cleanup && copy"

usage() {
    echo 
    echo "Builds the iOS app"
    echo "Usage: $0 [-ch]"
    echo
    echo "  -c       Only run cleanup"
    echo "  -h       Print this help message"
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
echo Build number: $NOW
echo Flavor: $flavor
echo 

if [[ -z "${CI}" ]]; then
  CODESIGN=""
else
  CODESIGN="--no-codesign"
fi

build() {
    echo "📦 Building the iOS app..."
    flutter build ipa --$flavor --build-number=$NOW --dart-define=BUILD=$BUILD $CODESIGN
}

cleanup() {
    echo "📁 Creating the output directory if it doesn't exist..."
    mkdir -p $CUR/out/ios

    echo "🗑  Removing previous releases..."
    rm -rf $CUR/out/ios/*
    rm -rf $CUR/out/ios/**/*

    echo "🌐 Generating payload..."
    mkdir -p $CUR/out/ios/Payload/Runner.app
}

copy() {
    echo "📑 Copying output files from their directory to our organized directory..."
    cp -r $CUR/build/ios/archive/Runner.xcarchive/Products/Applications/Runner.app/* $CUR/out/ios/Payload/Runner.app
    cd $CUR/out/ios
    zip -r $name-ios-$VER+$NOW-$flavor.ipa Payload
    rm -rf Payload
    cd -
}

eval $run
