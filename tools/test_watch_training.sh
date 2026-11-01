#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
task_dir=$(mktemp -d)
trap 'rm -rf "$task_dir"' EXIT
xcrun swiftc -module-cache-path "$task_dir/modules" -o "$task_dir/watch_training_test" \
  ios/Shared/WatchTraining.swift ios/Shared/QuillNoteDocument.swift test/native/watch_training.swift
"$task_dir/watch_training_test"
