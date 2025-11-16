#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="./repos"
PROCESSED_DIR="./processed"
APPS_DIR="../apps"

mkdir -p "$PROCESSED_DIR"

echo ""
echo "[POSTPROCESS] Starting post-processing of processed repos..."

# Ensure yq is installed
if ! command -v yq &>/dev/null; then
    echo "[ERROR] yq is required to parse YAML files."
    exit 1
fi

shopt -s nullglob

for processed in "$PROCESSED_DIR"/*; do
    [[ -d "$processed" ]] || continue
    foldername=$(basename "$processed")
    echo "[POSTPROCESS] Processing $foldername"

    # 1️⃣ Copy templates/*
    if [[ -d "./templates" ]]; then
        cp -r ./templates/* "$processed/" 2>/dev/null || echo "[WARN] Failed to copy templates for $foldername"
    fi
# ===== Extract Jenkins vars =====
JENKINS_YAML="$processed/jenkins-vars.yml"
README_YAML="$processed/readme-vars.yml"
SOURCE_FILE="$processed/source.txt"

echo "[POSTPROCESS] Extracting Jenkins variables..."

BUILD_VERSION_ARG=""
CI_WEB=""
CI_PORT=""
CI_SSL=""
CI_DOCKERENV=""
CI_AUTH=""
CI_WEBPATH=""
CI_CMD=""
SOURCE="UNKNOWNSOURCE"
VERSION="UNKNOWNVERSION"

if [[ -f "$JENKINS_YAML" ]]; then
BUILD_VERSION_ARG=$(yq e -r '.repo_vars[] | select(test("BUILD_VERSION_ARG")) | split("=")[1]' "$JENKINS_YAML")
CI_WEB=$(yq e -r '.repo_vars[] | select(test("CI_WEB")) | split("=")[1]' "$JENKINS_YAML")
CI_PORT=$(yq e -r '.repo_vars[] | select(test("CI_PORT")) | split("=")[1]' "$JENKINS_YAML")
CI_SSL=$(yq e -r '.repo_vars[] | select(test("CI_SSL")) | split("=")[1]' "$JENKINS_YAML")
CI_DOCKERENV=$(yq e -r '.repo_vars[] | select(test("CI_DOCKERENV")) | split("=")[1]' "$JENKINS_YAML")
CI_AUTH=$(yq e -r '.repo_vars[] | select(test("CI_AUTH")) | split("=")[1]' "$JENKINS_YAML")
CI_WEBPATH=$(yq e -r '.repo_vars[] | select(test("CI_WEBPATH")) | split("=")[1]' "$JENKINS_YAML")
CI_CMD=$(yq e -r '.repo_vars[] | select(test("CI_CMD")) | split("=")[1]' "$JENKINS_YAML")

else
    echo "[WARN] jenkins-vars.yml not found in $processed, skipping Jenkins vars extraction."
fi

if [[ -f "$README_YAML" ]]; then
SOURCE=$(yq e '.project_url' "$README_YAML")
else
    echo "[WARN] readme-vars.yml not found in $processed, skipping source extraction."
fi
# Optional: export if needed for subprocesses
export BUILD_VERSION_ARG CI_WEB CI_PORT CI_SSL CI_DOCKERENV CI_AUTH CI_WEBPATH CI_CMD SOURCE

# Clean up YAML
rm -rf "$JENKINS_YAML" || true
rm -rf "$README_YAML" || true


    # 2️⃣ Replace TEMPLATE in docker-bake.hcl
    docker_bake_file="$processed/docker-bake.hcl"
    version_file="$processed/version.txt"

    [[ -f "$version_file" ]] && VERSION=$(<"$version_file") && rm -rf "$version_file"
    VERSIONPREFIX=""
    if [[ "$VERSION" == v* ]]; then
  VERSION="${VERSION#v}"   # remove leading "v"
  VERSIONPREFIX="v"
fi

SOURCE=$(printf '%s\n' "$SOURCE" | sed 's/[&/\]/\\&/g')
    if [[ -f "$docker_bake_file" ]]; then
        if sed --version >/dev/null 2>&1; then
            sed -i "s/TEMPLATENAME/$foldername/g" "$docker_bake_file"
            sed -i "s/TEMPLATEVERSION/$VERSION/g" "$docker_bake_file"
            sed -i "s/TEMPLATESOURCE/$SOURCE/g" "$docker_bake_file"
        else
            sed -i '' "s/TEMPLATENAME/$foldername/g" "$docker_bake_file"
            sed -i '' "s/TEMPLATEVERSION/$VERSION/g" "$docker_bake_file"
            sed -i '' "s/TEMPLATESOURCE/$SOURCE/g" "$docker_bake_file"
        fi
    fi


    # 2️⃣ Replace TEMPLATEPORT in container_test.go
    container_test_file="$processed/container_test.go"
    container_test_file_web="$processed/container_test.go.web"
    container_test_file_cmd="$processed/container_test.go.cmd"
    container_test_file_port="$processed/container_test.go.port"
        replace_val=""
        if [[ "$CI_WEB" != "true" ]]; then
            mv $container_test_file_web "$container_test_file"
        elif [[ "$CI_PORT" != "" ]]; then
            mv $container_test_file_port "$container_test_file"
        elif [[ "$CI_CMD" != "" ]]; then
            mv $container_test_file_cmd "$container_test_file"
            else
mv $container_test_file_cmd "$container_test_file"
        fi
rm -rf "$container_test_file_web" "$container_test_file_cmd" "$container_test_file_port" || true

    if [[ -f "$container_test_file" ]]; then



     CI_WEBPATH=$(printf '%s\n' "$CI_WEBPATH" | sed 's/[&/\]/\\&/g')
        if sed --version >/dev/null 2>&1; then
            sed -i "s/CIPORT/$CI_PORT/g" "$container_test_file"

            sed -i "s/CIWEBPATH/$CI_WEBPATH/g" "$container_test_file"
            sed -i "s/CICMD/$CI_CMD/g" "$container_test_file"
        else
            sed -i '' "s/CIPORT/$CI_PORT/g" "$container_test_file"
            sed -i '' "s/CIWEBPATH/$CI_WEBPATH/g" "$container_test_file"
            sed -i '' "s/CICMD/$CI_CMD/g" "$container_test_file"
        fi
    fi

    rm -rf "$processed/Dockerfile.riscv64" && echo "[CLEANUP]: removed Dockerfile.riscv64" || true

    # 3️⃣ Clean empty svc-* folders and append run scripts to start.sh
    root_folder="$processed/root"
    etc_folder="$root_folder/etc"
    s6_root="$etc_folder/s6-overlay/"
    s6_dir="$s6_root/s6-rc.d"
    start_sh="$processed/start.sh"

    rm -rf "$root_folder/donate.txt" "$root_folder/migrations" || true

    if [[ -d "$s6_dir" ]]; then
        find "$s6_dir" -type f \( -name "type" -o -name "up" -o -name "notification-fd" \) -delete
        find "$s6_dir" -type d -empty -delete
        rm -rf "$s6_dir/init-deprecate" || true

        for init in "$s6_dir"/init-* "$s6_dir"/svc-*; do
            [[ -d "$init" ]] || continue
            run_file="$init/run"
            if [[ -f "$run_file" ]]; then
                echo "# ===== From $init/run =====" >> "$start_sh"
                cat "$run_file" >> "$start_sh"
                echo "" >> "$start_sh"
            fi
        done
    fi

    rm -rf "$s6_root" || true
    [[ -d "$etc_folder" && -z "$(ls -A "$etc_folder")" ]] && rm -rf "$etc_folder"
    [[ -d "$root_folder" && -z "$(ls -A "$root_folder")" ]] && rm -rf "$root_folder"

    # ===== Sanitize Dockerfiles =====
    dockerfiles=( "$processed/Dockerfile"* )
    [[ ${#dockerfiles[@]} -eq 0 ]] && continue

    echo "[VERBOSE] Cleaning up Dockerfiles in $processed: ${dockerfiles[*]}"
    BUILD_VERSION_ARG=${BUILD_VERSION_ARG//\'/}
    BUILD_VERSION_ARG=${BUILD_VERSION_ARG// /}
    echo "BUILD_VERSION_ARG set to $BUILD_VERSION_ARG"

for df in "${dockerfiles[@]}"; do
    if sed --version >/dev/null 2>&1; then
        sed -i \
            -e '/^LABEL build_version/d' \
            -e '/^LABEL maintainer/d' \
            -e '/^ARG BUILD_DATE/d' \
            -e '/^# syntax=docker\/dockerfile:1/d' \
            -e '/printf "Linuxserver\.io version/d' \
            -e "/ARG $BUILD_VERSION_ARG/d" \
            -e 's|^FROM ghcr.io/linuxserver/baseimage-alpine:|FROM ghcr.io/trueforge-org/ubuntu:24.4|g' \
            -e 's|^FROM ghcr.io/linuxserver/baseimage-ubuntu:|FROM ghcr.io/trueforge-org/ubuntu:24.4|g' \
            -e 's|^FROM ghcr.io/linuxserver/baseimage-debian:|FROM ghcr.io/trueforge-org/ubuntu:24.4|g' \
            -e "s/$BUILD_VERSION_ARG/VERSION/g" \
            -e "s/\${VERSION}/$VERSIONPREFIX\${VERSION}/g" \
            -e 's/amd64/\$TARGETARCH/g' \
            -e 's/x64/\$TARGETARCH/g' \
            -e 's/x86_64/\$TARGETARCH/g' \
            -e 's/arm64/\$TARGETARCH/g' \
            -e 's/aarch64/\$TARGETARCH/g' \
            -e 's/aarch/\$TARGETARCH/g' \
            -e '/^ARGVERSION/d' \
            "$df"
    else
        sed -i '' \
            -e '/^LABEL build_version/d' \
            -e '/^LABEL maintainer/d' \
            -e '/^ARG BUILD_DATE/d' \
            -e '/^# syntax=docker\/dockerfile:1/d' \
            -e '/printf "Linuxserver\.io version/d' \
            -e "/ARG $BUILD_VERSION_ARG/d" \
            -e 's|^FROM ghcr.io/linuxserver/baseimage-alpine:[^aA]*|FROM ghcr.io/trueforge-org/ubuntu:24.4|g' \
            -e 's|^FROM ghcr.io/linuxserver/baseimage-ubuntu:[^aA]*|FROM ghcr.io/trueforge-org/ubuntu:24.4|g' \
            -e 's|^FROM ghcr.io/linuxserver/baseimage-debian:[^aA]*|FROM ghcr.io/trueforge-org/ubuntu:24.4|g' \
            -e "s/$BUILD_VERSION_ARG/VERSION/g" \
            -e "s/\${VERSION}/$VERSIONPREFIX\${VERSION}/g" \
            -e 's/amd64/\$TARGETARCH/g' \
            -e 's/x64/\$TARGETARCH/g' \
            -e 's/x86_64/\$TARGETARCH/g' \
            -e 's/arm64/\$TARGETARCH/g' \
            -e 's/aarch64/\$TARGETARCH/g' \
            -e 's/aarch/\$TARGETARCH/g' \
            -e '/^ARGVERSION/d' \
            "$df"
    fi

    echo "[VERBOSE] Sanitized $df"
done


    # ===== Dockerfile Deduplication =====
    if [[ ${#dockerfiles[@]} -gt 1 ]]; then
        temp_dir=$(mktemp -d)
        for df in "${dockerfiles[@]}"; do
            temp_file="$temp_dir/$(basename "$df")"
            sed -E 's/^FROM .*/PLACEHOLDER/' "$df" > "$temp_file"
        done

        first_file=$(ls "$temp_dir" | head -n1)
        all_same=true
        for f in "$temp_dir"/*; do
            if ! cmp -s "$temp_dir/$first_file" "$f"; then
                all_same=false
                break
            fi
        done

        if $all_same; then
            echo "[POSTPROCESS] All Dockerfiles identical for $processed. Removing duplicates..."
            for df in "${dockerfiles[@]}"; do
                [[ $(basename "$df") == "Dockerfile" ]] || rm -f "$df"
            done
        fi

        rm -rf "$temp_dir"
    fi
done

shopt -u nullglob
