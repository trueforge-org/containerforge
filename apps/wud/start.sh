#!/usr/bin/env bash
set -e

COMPOSE_DIR="${COMPOSE_DIR:-''}"
COMPOSE_THRESHOLD="${THRESHOLD:-minor}"

declare -A app_files

if [[ "$COMPOSE_DIR" != "" ]]; then
    while IFS= read -r -d '' file; do
        dir=$(dirname "$file")
        foldername=$(echo "$dir" | sed "s|$COMPOSE_DIR/||" | cut -d'/' -f1)

        if [[ -n "${app_files[$foldername]}" ]]; then
            echo "⚠ Warning: Multiple compose files detected for app '$foldername':"
            echo "    ${app_files[$foldername]}"
            echo "    $file"
        fi

        app_files[$foldername]="$file"
    done < <(find "$COMPOSE_DIR" -type f \( \
        -name "compose.yaml" -o \
        -name "compose.yml" -o \
        -name "docker-compose.yaml" -o \
        -name "docker-compose.yml" \
    \) -print0)

    for folder in "${!app_files[@]}"; do
        safe_folder=$(echo "$folder" | tr '-' '_' | tr '[:lower:]' '[:upper:]')
        compose_file="${app_files[$folder]}"
        export WUD_TRIGGER_DOCKERCOMPOSE_${safe_folder}_FILE="$compose_file"
        export WUD_TRIGGER_DOCKERCOMPOSE_${safe_folder}_THRESHOLD="$COMPOSE_THRESHOLD"
    done
fi

node index "$@" | /app/node_modules/.bin/bunyan -L -o short
