#!/bin/bash
set -euo pipefail

SOURCE_DIR="/mnt/.ix-apps/app_configs"
TARGET_DIR="/mnt/tank/apps"

# Loop through all folders in the source directory
for app_path in "$SOURCE_DIR"/*/; do
    appname=$(basename "$app_path")
    versions_dir="$app_path/versions"

    # Skip if versions directory doesn't exist
    if [[ ! -d "$versions_dir" ]]; then
        echo "No versions folder for $appname, skipping..."
        continue
    fi

    # Find the highest semver folder
    highest_version=$(ls "$versions_dir" | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' | sort -V | tail -n1)

    if [[ -z "$highest_version" ]]; then
        echo "No valid version folders found for $appname, skipping..."
        continue
    fi

    source_compose="$versions_dir/$highest_version/templates/rendered/docker-compose.yaml"
    target_compose="$TARGET_DIR/$appname/compose.yaml"

    # Ensure target folder exists
    mkdir -p "$TARGET_DIR/$appname"

    # Copy docker-compose file
    if [[ -f "$source_compose" ]]; then
        cp "$source_compose" "$target_compose"
        echo "Copied $source_compose to $target_compose"

        # Check if file ends with '}' (Truenas JSON format)
        if tail -c 1 "$target_compose" | grep -q '}'; then
            echo "Detected Truenas port format, processing $target_compose..."

            # Backup original
            cp "$target_compose" "$target_compose.bak"

            # Remove specified keys using jq
            jq '
              del(
                .["x-portals"],
                .["x-notes"],
                .services.permissions,
                .configs.permissions_actions_data,
                .configs.permissions_run_script
              )
              | .services |= with_entries(
                  .value |= if (.depends_on | type == "object") and (.depends_on | has("permissions"))
                            then .depends_on |= del(.permissions)
                            else . end
                )
            ' "$target_compose" > "$target_compose.tmp" \
            && mv "$target_compose.tmp" "$target_compose"

            echo "Processed $target_compose (backup saved as $target_compose.bak)"
        fi

    else
        echo "docker-compose at location $source_compose not found for $appname version $highest_version, skipping..."
    fi
done
