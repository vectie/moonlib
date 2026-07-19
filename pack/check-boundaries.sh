#!/bin/sh
set -eu

root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$root"

if rg -n '\b(moonfish|mooncast|InvestmentIdea|Campaign)\b' \
  pack -g '*.mbt' -g moon.pkg; then
  echo "generic pack SDK contains domain-specific vocabulary" >&2
  exit 1
fi

if rg -n '"vectie/(moonfish|mooncast)' pack -g moon.pkg; then
  echo "generic pack SDK imports a domain repository" >&2
  exit 1
fi

echo "pack SDK boundary check passed"
