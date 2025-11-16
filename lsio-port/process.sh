#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="./repos"
PROCESSED_DIR="./processed"
APPS_DIR="../apps"

mkdir -p "$REPO_DIR" "$PROCESSED_DIR"

echo "[*] Fetching ALL LinuxServer.io repositories (with pagination)..."

all_repos=""
page=1


# ===== PostProcessing =====
echo ""
echo "[POSTPROCESS] Starting post-processing of processed repos..."

for processed in "$PROCESSED_DIR"/*; do
    [[ -d "$processed" ]] || continue
    foldername=$(basename "$processed")
    echo "[POSTPROCESS] Processing $foldername"

    # 1️⃣ Copy templates/*
    if [[ -d "./templates" ]]; then
        cp -r ./templates/* "$processed/" 2>/dev/null || echo "[WARN] Failed to copy templates for $foldername"
    fi

    # 2️⃣ Replace TEMPLATE in docker-bake.hcl
    docker_bake_file="$processed/docker-bake.hcl"
    if [[ -f "$docker_bake_file" ]]; then
        if sed --version >/dev/null 2>&1; then
            # GNU sed
            sed -i "s/TEMPLATE/$foldername/g" "$docker_bake_file"
        else
            # macOS / BSD sed
            sed -i '' "s/TEMPLATE/$foldername/g" "$docker_bake_file"
        fi
    fi

# 3️⃣ Clean empty svc-* folders and append run scripts to start.sh
root_folder="$processed/root"
etc_folder="$root_folder/etc"
s6_root="$etc_folder/s6-overlay/"
s6_dir="$s6_root/s6-rc.d"
start_sh="$processed/start.sh"


if [[ -d "$s6_dir" ]]; then
    for subdir in "$s6_dir"/*; do
        [[ -d "$subdir" ]] || continue
        rm -f "$subdir/type" || true
        rm -f "$subdir/up" || true
        rm -f "$subdir/notification-fd" || true
        echo "[CLEANUP] Removed unnecessary files..."
    done
# Find all directories recursively, deepest first
find "$s6_dir" -type d -depth | while IFS= read -r dir; do
    all_empty=true

    # Check if directory contains any non-empty files
    while IFS= read -r -d '' file; do
        if [[ -s "$file" ]]; then
            all_empty=false
            break
        fi
    done < <(find "$dir" -type f -print0)

    # If directory contains no files or subdirectories, consider it empty
    if [[ $(find "$dir" -mindepth 1 | wc -l) -eq 0 ]]; then
        all_empty=true
    fi

    if $all_empty; then
        rm -rf "$dir"
    fi
    echo "[CLEANUP] Removed empty folders..."
done
    rm -rf "$s6_dir/init-deprecate" && echo "[CLEANUP] Deleted deprecation notice..." || true
    for init in "$s6_dir"/init-*; do
        [[ -d "$init" ]] || continue


        # Append run script if exists
        run_file="$init/run"
        if [[ -f "$run_file" ]]; then
            echo "# ===== From $init/run =====" >> "$start_sh"
            cat "$run_file" >> "$start_sh"
            echo "" >> "$start_sh"
        fi
    done
    for svc in "$s6_dir"/svc-*; do
        [[ -d "$svc" ]] || continue


        # Append run script if exists
        run_file="$svc/run"
        if [[ -f "$run_file" ]]; then
            echo "# ===== From $svc/run =====" >> "$start_sh"
            cat "$run_file" >> "$start_sh"
            echo "" >> "$start_sh"
        fi
    done
fi
rm -rf $s6_root || true
echo "[CLEANUP] Removed s6-overlay root folder..."

if [ -d "$etc_folder" ] && [ -z "$(ls -A "$etc_folder")" ]; then
    rm -rf "$etc_folder"
    echo "[CLEANUP] Removed empty etc folder..."
fi

if [ -d "$root_folder" ] && [ -z "$(ls -A "$root_folder")" ]; then
    rm -rf "$root_folder"
    echo "[CLEANUP] Removed empty root folder..."
fi

done
