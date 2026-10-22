#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
task_dir=$(mktemp -d)
trap 'rm -rf "$task_dir"' EXIT
xcrun swiftc -module-cache-path "$task_dir/modules" -o "$task_dir/watch_food_test" \
  ios/Shared/Model/NativeFoodNutritionSplit.swift \
  ios/Shared/Model/NativeFoodCategory.swift \
  ios/Shared/Model/NativeFoodStateMessage.swift \
  'ios/GymBroWatch Watch App/FoodMessageDelegate.swift' \
  'ios/GymBroWatch Watch App/FoodViewModel.swift' \
  test/native/watch_food_sync.swift
"$task_dir/watch_food_test"
