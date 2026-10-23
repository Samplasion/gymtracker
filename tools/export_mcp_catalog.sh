#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
"${FLUTTER:-flutter}" test --no-pub tools/export_mcp_catalog.dart "$@"
