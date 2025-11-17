#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="./repos"
PROCESSED_DIR="./processed"
APPS_DIR="../apps"
DISTROS=("debian" "ubuntu" "arch" "fedora" "alpine" "centos" "rocky" "openSUSE" "opensuse" "photon" "clearlinux" "el")
BLACKLIST=("nextcloud" "ci" "build-agent" "jenkins-builder" "d2-builder" "documentation" "fleet" "homeassistant" "hubstats" "lsio-api" "manifest-tool" "modmanager" "selkies")
source ./GITHUB_TOKEN.env || echo "[INFO] No GITHUB_TOKEN.env file found, proceeding without GitHub token."
GITHUB_TOKEN="${GITHUB_TOKEN:-}"
NOREPULL="${NOREPULL:="false"}"

# Set curl auth header only if token is set
if [[ -n "$GITHUB_TOKEN" ]]; then
    CURL_AUTH_HEADER=(-H "Authorization: token $GITHUB_TOKEN")
else
    CURL_AUTH_HEADER=()
fi

mkdir -p "$REPO_DIR" "$PROCESSED_DIR"

echo "[*] Fetching ALL LinuxServer.io repositories (with pagination)..."

all_repos=""
page=1

rm -rf processed && echo "deleted processed folder..." || true

while true; do
    echo "[*] Fetching page $page..."
resp=$(curl -s "${CURL_AUTH_HEADER[@]}" \
            "https://api.github.com/orgs/linuxserver/repos?per_page=100&page=$page" \
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
skipped_distro_apps=0
skipped_blacklist_apps=0
skipped_done_apps=0
processed_repos=0
failed_copies=()
based_on_selkies=0
no_dockerfile_skipped=0

# ===== Clone / Pull & Copy =====
for repo in $repos; do
    # Remove docker- prefix
    shortname="${repo#docker-}"
    # Remove alpine- prefix
    shortname="${shortname#alpine-}"
    # Remove baseimage- prefix
    shortname="${shortname#baseimage-}"
    # Remove alpine- prefix
    shortname="${shortname#alpine-}"
    target="$REPO_DIR/$shortname"

    # Skip if $shortname is in BLACKLIST before cloning
    if [[ " ${BLACKLIST[*]} " == *" $shortname "* ]]; then
        echo "[SKIP] '$shortname' is blacklisted, skipping clone/pull."
        rm -rf $target || true
        ((skipped_blacklist_apps++))
        continue
    fi

    # Skip if $shortname is in DISTROS before cloning
    if [[ " ${DISTROS[*]} " == *" $shortname "* ]]; then
        echo "[SKIP] '$shortname' is a distro, skipping clone/pull."
        rm -rf $target || true
        ((skipped_distro_apps++))
        continue
    fi

    # Skip if exists under ../apps
    if [[ -d "$APPS_DIR/$shortname" ]]; then
        echo "[SKIP] '$shortname' exists under ../apps, clone/pull."
        rm -rf $target || true
        ((skipped_done_apps++))
        continue
    fi

    # Clone or pull
    if [[ "$NOREPULL" == "true" && -d "$target" ]]; then
        echo "[SKIP] NOREPULL is set, skipping pull for $shortname"
    elif [[ -d "$target" ]]; then
        echo "[PULL] Updating $shortname"
        git -C "$target" pull --quiet || echo "[WARN] git pull failed for $shortname"
    else
        echo "[CLONE] Cloning $repo → $target"
        git clone --quiet "https://github.com/linuxserver/$repo.git" "$target" || echo "[WARN] git clone failed for $shortname"
    fi

    # ===== Fetch latest GitHub release version =====
latest_release=$(curl -s "${CURL_AUTH_HEADER[@]}" \
                     "https://api.github.com/repos/linuxserver/$repo/releases/latest" \
                     | jq -r '.tag_name')
    # Remove -ls* suffix
    clean_version=$(echo "$latest_release" | sed 's/-ls.*//')
    echo "$clean_version" > "$target/version.txt"

    # ===== Check Dockerfiles for baseimage-selkies =====
    skip_due_to_selkies=false
    shopt -s nullglob nocaseglob
    dockerfiles=("$target"/Dockerfile*)
    if [[ ${#dockerfiles[@]} -eq 0 ]]; then
        echo "[SKIP] '$shortname' has no Dockerfile, skipping processed copy."
        ((no_dockerfile_skipped++))
        shopt -u nullglob nocaseglob
        continue
    fi

    for df in "${dockerfiles[@]}"; do
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

        # Copy Dockerfiles
        for df in "${dockerfiles[@]}"; do
            if ! cp "$df" "$out_dir/"; then
                echo "[WARN] Failed to copy $df"
                copy_failed=true
            fi
        done

        # Copy root folder if exists
        if [[ -d "$target/root" ]]; then
            if ! cp -r "$target/root" "$out_dir/"; then
                echo "[WARN] Failed to copy root/ folder for $shortname"
                copy_failed=true
            fi
        fi

        # Copy version.txt
        if ! cp "$target/version.txt" "$out_dir/"; then
            echo "[WARN] no version.txt for $shortname"
            rm -rf "$target/version.txt" || true
        fi

        # Copy jenkins-vars.yml
        if ! cp "$target/jenkins-vars.yml" "$out_dir/"; then
            echo "[WARN] no jenkins-vars.yml for $shortname"
        fi

        # Copy readme-vars.yml
        if ! cp "$target/readme-vars.yml" "$out_dir/"; then
            echo "[WARN] no readme-vars.yml for $shortname"
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
echo "Skipped (app is blacklisted):         $skipped_blacklist_apps"
echo "Skipped (app is distro):         $skipped_distro_apps"
echo "Skipped (../apps exists):         $skipped_done_apps"
echo "Skipped (baseimage-selkies):     $based_on_selkies"
echo "Skipped (no Dockerfile):          $no_dockerfile_skipped"
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
