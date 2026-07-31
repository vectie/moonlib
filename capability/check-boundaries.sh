#!/bin/sh
set -eu

root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$root"

if rg -n '"vectie/moon' capability -g moon.pkg; then
  echo "capability contracts import a MoonSuite product or policy package" >&2
  exit 1
fi

if rg -n \
  '\b(claim_rank|authority_rank|compile_catalog|execute_adapter|start_daemon)\b' \
  capability -g '*.mbt'; then
  echo "capability contracts contain compiler, policy, or runtime behavior" >&2
  exit 1
fi

echo "capability contract boundary check passed"
