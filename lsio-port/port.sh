#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="./repos"
PROCESSED_DIR="./processed"
APPS_DIR="../apps"

mkdir -p "$REPO_DIR" "$PROCESSED_DIR"

 echo "[*] Fetching ALL LinuxServer.io repositories (with pagination)..."

 all_repos=""
 page=1

 while true; do
     echo "[*] Fetching page $page..."
     resp=$(curl -s "https://api.github.com/orgs/linuxserver/repos?per_page=100&page=$page" \
             | jq -r '.[].name')

     [[ -z "$resp" ]] && break

     all_repos="$all_repos"$'\n'"$resp"
     ((page++))
 done

 # Remove blank lines
 all_repos=$(echo "$all_repos" | sed '/^\s*$/d')

 total_all_repos=$(echo "$all_repos" | wc -l | tr -d ' ')
 echo "[*] Total repos under linuxserver.io: $total_all_repos"

 # Filter docker-* repos
 repos=$(echo "$all_repos" | grep '^docker-')
 total_docker_repos=$(echo "$repos" | wc -l | tr -d ' ')
 echo "[*] Total docker-* repos: $total_docker_repos"

 skipped_apps=0
 processed_repos=0
 failed_copies=()

 for repo in $repos; do
     # Remove docker- prefix
     shortname="${repo#docker-}"

     # Remove baseimage- prefix if present
     shortname="${shortname#baseimage-}"

     target="$REPO_DIR/$shortname"

     # Skip if exists under ../apps
     if [[ -d "$APPS_DIR/$shortname" ]]; then
         echo "[SKIP] '$shortname' exists under ../apps, skipping."
         ((skipped_apps++))
         continue
     fi

     # Clone or update
     if [[ -d "$target" ]]; then
         echo "[PULL] Updating $shortname"
         git -C "$target" pull --quiet || echo "[WARN] git pull failed for $shortname"
     else
         echo "[CLONE] Cloning $repo → $target"
         git clone --quiet "https://github.com/linuxserver/$repo.git" "$target" || echo "[WARN] git clone failed for $shortname"
     fi

     # Process copy (non-failing)
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
 done


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


    # 3️⃣ Append svc-* run scripts to start.sh
    s6_dir="$processed/root/etc/s6-overlay/s6-rc.d"
    start_sh="$processed/start.sh"

    if [[ -d "$s6_dir" ]]; then
        for svc in "$s6_dir"/svc-*; do
            [[ -d "$svc" ]] || continue
            run_file="$svc/run"
            if [[ -f "$run_file" ]]; then
                echo "# ===== From $svc/run =====" >> "$start_sh"
                cat "$run_file" >> "$start_sh"
                echo "" >> "$start_sh"
            fi
        done
    fi
done

echo "[POSTPROCESS] Done."

echo ""
echo "==================== SUMMARY ===================="
echo "Total repos under linuxserver.io: $total_all_repos"
echo "Total docker-* repos:             $total_docker_repos"
echo "Skipped (../apps exists):         $skipped_apps"
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
