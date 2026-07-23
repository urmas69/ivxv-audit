#!/usr/bin/env bash
set -Eeuo pipefail
ROOT=${1:-$(pwd)}; bad=0
while IFS= read -r path; do [ -e "$ROOT/reports/$path" ] || { echo "missing report link $path"; bad=1; }; done < <(rg -o '\]\([^)]+' "$ROOT/reports" | sed 's/.*](//' | grep -v '^\.\./')
exit "$bad"
