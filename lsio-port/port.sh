#!/usr/bin/env bash
set -euo pipefail

# Base directories
REPO_DIR="./repos"
PROCESSED_DIR="./processed"
APPS_DIR="../apps"

mkdir -p "$REPO_DIR"
mkdir -p "$PROCESSED_DIR"

echo "[*] Fetching repo list from linuxserver.io..."

# Fetch all repos
all_repos=$(curl -s "https://api.github.com/orgs/linuxserver/repos?per_page=500" \
    | jq -r '.[].name')

total_all_repos=$(echo "$all_repos" | wc -l | tr -d ' ')

# Filter docker-* repos
repos=$(echo "$all_repos" | grep '^docker-')
total_docker_repos=$(echo "$repos" | wc -l | tr -d ' ')

echo "[*] Found $total_all_repos total repos under linuxserver.io."
echo "[*] Found $total_docker_repos docker-* repos."

# Counters
skipped_apps=0
processed_repos=0

for repo in $repos; do
    shortname="${repo#docker-}"
    target="$REPO_DIR/$shortname"

    # Skip if exists under ../apps
    if [[ -d "$APPS_DIR/$shortname" ]]; then
        echo "[SKIP] '$shortname' exists under ../apps, skipping entirely."
        ((skipped_apps++))
        continue
    fi

    # Clone or pull
    if [[ -d "$target" ]]; then
        echo "[PULL] Updating existing repo: $shortname"
        git -C "$target" pull --quiet
    else
        echo "[CLONE] Cloning $repo into $target"
        git clone --quiet "https://github.com/linuxserver/$repo.git" "$target"
    fi

    # Process copying
    out_dir="$PROCESSED_DIR/$shortname"
    mkdir -p "$out_dir"

    echo "[PROCESS] Copying Dockerfiles and root/ for $shortname"

    shopt -s nullglob nocaseglob
    for df in "$target"/Dockerfile*; do
        [[ -f "$df" ]] && cp "$df" "$out_dir/"
    done
    shopt -u nullglob nocaseglob

    if [[ -d "$target/root" ]]; then
        cp -r "$target/root" "$out_dir/"
    fi

    ((processed_repos++))
done

echo ""
echo "==================== SUMMARY ===================="
echo "Total repos under linuxserver.io: $total_all_repos"
echo "Matched repos (docker-*):        $total_docker_repos"
echo "Skipped due to ../apps/:         $skipped_apps"
echo "Total processed:                 $processed_repos"
echo "================================================="
echo ""
echo "[DONE] All operations complete."
