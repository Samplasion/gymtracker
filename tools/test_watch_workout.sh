#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
task_dir=$(mktemp -d)
trap 'rm -rf "$task_dir"' EXIT
xcrun swiftc -module-cache-path "$task_dir/modules" -o "$task_dir/watch_workout_test" \
  ios/Shared/WorkoutLifecycle.swift test/native/watch_workout_lifecycle.swift
"$task_dir/watch_workout_test"
