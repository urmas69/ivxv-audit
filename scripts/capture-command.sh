#!/usr/bin/env bash
set -Eeuo pipefail

if (( $# < 2 )); then
    echo "usage: $0 OUTPUT COMMAND [ARG ...]" >&2
    exit 64
fi

output=$1
shift
mkdir -p "$(dirname "$output")"
tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT

started=$(date -u +%Y-%m-%dT%H:%M:%SZ)
cwd=$(pwd -P)
printf -v quoted '%q ' "$@"

set +e
"$@" >"$tmp" 2>&1
status=$?
set -e

{
    printf 'UTC timestamp: %s\n' "$started"
    printf 'Working directory: %s\n' "$cwd"
    printf 'Command: %s\n' "${quoted% }"
    printf 'Environment: PATH=%s; LANG=%s; LC_ALL=%s\n' \
        "$PATH" "${LANG-}" "${LC_ALL-}"
    printf 'Exit status: %d\n' "$status"
    printf '%s\n' '--- combined stdout and stderr ---'
    sed 's/\r$//' "$tmp"
} >"$output"

exit "$status"
