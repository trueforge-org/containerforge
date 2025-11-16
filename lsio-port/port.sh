#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="./repos"
PROCESSED_DIR="./processed"
APPS_DIR="../apps"
DISTROS=("debian" "ubuntu" "arch" "fedora")

mkdir -p "$REPO_DIR" "$PROCESSED_DIR"

echo "[*] Fetching ALL LinuxServer.io repositories (with pagination)..."

all_repos=""
page=1

rm -rf processed && echo "deleted processed folder..." || true

while true; do
    echo "[*] Fetching page $page..."
    resp=$(curl -s "https://api.github.com/orgs/linuxserver/repos?per_page=100&page=$page" \
            | jq -r '.[].name')

    [[ -z "$resp" ]] && break

    all_repos="$all_repos"$'\n'"$resp"
    ((page++))
done

# Clean empty lines
all_repos=$(echo "$all_repos" | sed '/^\s*$/d')
total_all_repos=$(echo "$all_repos" | wc -l | tr -d ' ')
echo "[*] Total repos under linuxserver.io: $total_all_repos"

# Filter docker-* repos
repos=$(echo "$all_repos" | grep '^docker-')
total_docker_repos=$(echo "$repos" | wc -l | tr -d ' ')
echo "[*] Total docker-* repos: $total_docker_repos"

# Counters
skipped_apps=0
processed_repos=0
failed_copies=()
based_on_selkies=0

# ===== Clone / Pull & Copy =====
for repo in $repos; do
    # Remove docker- prefix
    shortname="${repo#docker-}"
    # Remove baseimage- prefix
    shortname="${shortname#baseimage-}"

    target="$REPO_DIR/$shortname"

    # Skip if exists under ../apps
    if [[ -d "$APPS_DIR/$shortname" ]]; then
        echo "[SKIP] '$shortname' exists under ../apps, skipping."
        ((skipped_apps++))
        continue
    fi

# Skip if $shortname is in DISTROS
if [[ " ${DISTROS[*]} " == *" $shortname "* ]]; then
    echo "[SKIP] '$shortname' is a distro, skipping."
    ((skipped_apps++))
    continue
fi

    # Clone or pull
    if [[ -d "$target" ]]; then
        echo "[PULL] Updating $shortname"
        git -C "$target" pull --quiet || echo "[WARN] git pull failed for $shortname"
    else
        echo "[CLONE] Cloning $repo → $target"
        git clone --quiet "https://github.com/linuxserver/$repo.git" "$target" || echo "[WARN] git clone failed for $shortname"
    fi

    # ===== Check Dockerfiles for baseimage-selkies =====
    skip_due_to_selkies=false
    shopt -s nullglob nocaseglob
    for df in "$target"/Dockerfile*; do
        if grep -q "FROM ghcr.io/linuxserver/baseimage-selkies" "$df"; then
            echo "[SKIP] '$shortname' uses baseimage-selkies, skipping processed copy."
            skip_due_to_selkies=true
            ((based_on_selkies++))
            break
        fi
    done
    shopt -u nullglob nocaseglob

    # ===== Copy to processed/ if allowed =====
    if ! $skip_due_to_selkies; then
        out_dir="$PROCESSED_DIR/$shortname"
        mkdir -p "$out_dir"
        echo "[PROCESS] Copying files for $shortname"

        shopt -s nullglob nocaseglob
        copy_failed=false

        for df in "$target"/Dockerfile*; do
            if ! cp "$df" "$out_dir/"; then
                echo "[WARN] Failed to copy $df"
                copy_failed=true
            fi
        done

        if [[ -d "$target/root" ]]; then
            if ! cp -r "$target/root" "$out_dir/"; then
                echo "[WARN] Failed to copy root/ folder for $shortname"
                copy_failed=true
            fi
        fi
        shopt -u nullglob nocaseglob

        if $copy_failed; then
            failed_copies+=("$shortname")
        fi

        ((processed_repos++))
    fi
done

source ./process.sh

# ===== SUMMARY =====
echo ""
echo "==================== SUMMARY ===================="
echo "Total repos under linuxserver.io: $total_all_repos"
echo "Total docker-* repos:             $total_docker_repos"
echo "Skipped (../apps exists):         $skipped_apps"
echo "Skipped (baseimage-selkies):     $based_on_selkies"
echo "Processed repos:                  $processed_repos"

if (( ${#failed_copies[@]} > 0 )); then
    echo ""
    echo "[WARN] Failed copies for the following repos:"
    for f in "${failed_copies[@]}"; do
        echo " - $f"
    done
else
    echo "[INFO] All copies succeeded."
fi

echo "================================================="
echo "[DONE]"
