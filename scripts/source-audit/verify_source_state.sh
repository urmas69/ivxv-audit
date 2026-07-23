#!/usr/bin/env bash
set -Eeuo pipefail
SRC=${1:-/home/audit/audit/ivxv}; expected=2785872f84dffb56bbecc41b096a7ee0f2876e64
actual=$(git -C "$SRC" rev-parse HEAD); [ "$actual" = "$expected" ] || { echo "wrong commit: $actual" >&2; exit 2; }
[ -z "$(git -C "$SRC" status --porcelain=v1)" ] || { git -C "$SRC" status --porcelain=v1; exit 3; }
printf 'UTC=%s commit=%s clean=yes\n' "$(date -u +%FT%TZ)" "$actual"
