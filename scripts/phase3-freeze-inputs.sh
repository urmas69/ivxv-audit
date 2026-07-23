#!/usr/bin/env bash
set -Eeuo pipefail

if [[ $# -ne 2 ]]; then
  echo "usage: $0 SOURCE OUTPUT" >&2
  exit 64
fi
source=$(realpath "$1")
output=$(realpath -m "$2")
mkdir -p "$output"
{
  date -u +%Y-%m-%dT%H:%M:%SZ
  git -C "$source" rev-parse HEAD
  git -C "$source" ls-tree -r --name-only HEAD | LC_ALL=C sort | \
    rg '(go\.mod|go\.sum|build\.gradle|setup\.py|package(-lock)?\.json|debian/control|debian/rules)$' || true
} > "$output/source-dependency-declarations.txt"
if [[ -f "$source/evidence/dependency-manifests/dependency-provenance.csv" ]]; then
  cp "$source/evidence/dependency-manifests/dependency-provenance.csv" "$output/" # reconstruction only
fi
