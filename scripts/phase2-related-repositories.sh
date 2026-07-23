#!/usr/bin/env bash
set -Eeuo pipefail
trap 'status=$?; printf "\nexit_status=%s\n" "$status"' EXIT

printf 'timestamp_utc=%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
printf 'cwd=%s\n' "$PWD"
printf 'command=%q\n' "$0"
printf 'git_version=%s\ncurl_version=%s\njq_version=%s\n' \
    "$(git --version)" "$(curl --version | head -n1)" "$(jq --version)"

for remote in \
    https://github.com/valimised/ivxv.git \
    https://github.com/urmas69/ivxv.git
do
    printf '\n[git ls-remote --symref %s]\n' "$remote"
    git ls-remote --symref "$remote"
done

printf '\n[GET %s]\n' 'https://api.github.com/orgs/valimised/repos?per_page=100'
curl --fail-with-body --location --silent --show-error \
    -H 'Accept: application/vnd.github+json' \
    'https://api.github.com/orgs/valimised/repos?per_page=100' |
    jq -S '[.[] | {full_name, clone_url, default_branch, archived, description}] |
        sort_by(.full_name)'
printf '\n[GET %s]\n' 'https://api.github.com/repos/valimised/ivxv/releases?per_page=100'
curl --fail-with-body --location --silent --show-error \
    -H 'Accept: application/vnd.github+json' \
    'https://api.github.com/repos/valimised/ivxv/releases?per_page=100' |
    jq -S .
printf '\n[GET %s]\n' 'https://api.github.com/repos/valimised/ivxv/tags?per_page=100'
curl --fail-with-body --location --silent --show-error \
    -H 'Accept: application/vnd.github+json' \
    'https://api.github.com/repos/valimised/ivxv/tags?per_page=100' |
    jq -S .
printf '\n[GET %s]\n' 'https://api.github.com/repos/valimised/ivxv/forks?per_page=100&sort=oldest'
curl --fail-with-body --location --silent --show-error \
    -H 'Accept: application/vnd.github+json' \
    'https://api.github.com/repos/valimised/ivxv/forks?per_page=100&sort=oldest' |
    jq -S '[.[] | {full_name, clone_url, default_branch, pushed_at}] |
        sort_by(.full_name)'

for repo in urmas69/ivxv worldpeaceworker/ivxv tungnk-dev/ivxv \
    ivokub/ivxv Gravity-I-Pull-You-Down/ivxv
do
    url="https://api.github.com/repos/${repo}/contents/common/external/database/etcd"
    printf '\n[expected-negative GET %s]\n' "$url"
    status=$(curl --location --silent --show-error \
        --output /dev/null --write-out '%{http_code}' \
        -H 'Accept: application/vnd.github+json' "$url")
    printf 'http_status=%s\n' "$status"
    if [[ "$status" != 200 && "$status" != 404 ]]; then
        printf 'ERROR: unexpected HTTP status for %s\n' "$url" >&2
        exit 1
    fi
done
