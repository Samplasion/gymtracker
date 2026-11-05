#!/usr/bin/env bash
# Use a fresh Flutter process per suite: the macOS log reader cannot reliably
# reconnect after the first integration-test executable exits.
set -uo pipefail
cd "$(dirname "$0")/.."
flutter_bin="${FLUTTER_BIN:-.fvm/flutter_sdk/bin/flutter}"
if [[ ! -x "$flutter_bin" ]]; then flutter_bin=flutter; fi
failed=()
for suite in integration_test/*_test.dart; do
  if [[ "$suite" == integration_test/app_store_screenshots_test.dart ||
        "$suite" == integration_test/apple_watch_*_test.dart ]]; then
    continue
  fi
  echo "Running $suite"
  if ! "$flutter_bin" test "$suite" -d macos "$@"; then
    failed+=("$suite")
  fi
done
if (( ${#failed[@]} )); then
  printf 'Failed suite: %s\n' "${failed[@]}"
  exit 1
fi
