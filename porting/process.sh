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

BUILD_VERSION_ARG=${BUILD_VERSION_ARG//\'/}
CI_WEB=${CI_WEB//\'/}
CI_PORT=${CI_PORT//\'/}
CI_SSL=${CI_SSL//\'/}
CI_DOCKERENV=${CI_DOCKERENV//\'/}
CI_AUTH=${CI_AUTH//\'/}
CI_WEBPATH=${CI_WEBPATH//\'/}
CI_CMD=${CI_CMD//\'/}
BUILD_VERSION_ARG=${BUILD_VERSION_ARG//\'/}

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

    # Ensure standardized docker-bake.hcl exists for processing
    if [[ ! -f "$docker_bake_file" && -f "./templates/docker-bake.hcl" ]]; then
        cp ./templates/docker-bake.hcl "$docker_bake_file" || {
            echo "[ERROR] Failed to create standardized docker-bake.hcl for $foldername"
            exit 1
        }
    fi

    [[ -f "$version_file" ]] && VERSION=$(<"$version_file") && rm -rf "$version_file"
    VERSIONPREFIX=""
    if [[ "$VERSION" == v* ]]; then
  VERSION="${VERSION#v}"   # remove leading "v"
  VERSIONPREFIX="v"
fi

    RENOVATE_DEP="linuxserver/docker-$foldername"
    if [[ "$SOURCE" =~ ^https?://github\.com/([^/]+)/([^/?#]+) ]]; then
        RENOVATE_DEP="${BASH_REMATCH[1]}/${BASH_REMATCH[2]%.git}"
    fi

    SOURCE=$(printf '%s\n' "$SOURCE" | sed 's/[&/\]/\\&/g')
    RENOVATE_DEP=$(printf '%s\n' "$RENOVATE_DEP" | sed 's/[&/\]/\\&/g')
    if [[ -f "$docker_bake_file" ]]; then
        if sed --version >/dev/null 2>&1; then
            sed -i "s/TEMPLATENAME/$foldername/g" "$docker_bake_file"
            sed -i "s/TEMPLATEVERSION/$VERSION/g" "$docker_bake_file"
            sed -i "s/TEMPLATESOURCE/$SOURCE/g" "$docker_bake_file"
            sed -i "s/TEMPLATERENOVATEDEP/$RENOVATE_DEP/g" "$docker_bake_file"
        else
            sed -i '' "s/TEMPLATENAME/$foldername/g" "$docker_bake_file"
            sed -i '' "s/TEMPLATEVERSION/$VERSION/g" "$docker_bake_file"
            sed -i '' "s/TEMPLATESOURCE/$SOURCE/g" "$docker_bake_file"
            sed -i '' "s/TEMPLATERENOVATEDEP/$RENOVATE_DEP/g" "$docker_bake_file"
        fi
    fi

    rm -rf "$processed/Dockerfile.riscv64" && echo "[CLEANUP]: removed Dockerfile.riscv64" || true

    # 2️⃣ Clean empty svc-* folders and append run scripts to start.sh
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
    CURRENT_BASE=$(awk '/^FROM / { print $2; exit }' "$df")
    BASE_IMAGE="ghcr.io/trueforge-org/ubuntu:24.04"
    if grep -qiE '\b(javac|java|jdk|jre|mvn|maven|gradle)\b' "$df"; then
        BASE_IMAGE="ghcr.io/trueforge-org/java17:17"
    elif grep -qiE '\b(go build|go mod|golang)\b' "$df"; then
        BASE_IMAGE="ghcr.io/trueforge-org/golang:1.26.0"
    elif grep -qiE '\b(npm|nodejs|yarn|pnpm)\b' "$df"; then
        BASE_IMAGE="ghcr.io/trueforge-org/node:22.22.0"
    elif grep -qiE '\b(python|pip|venv)\b' "$df"; then
        BASE_IMAGE="ghcr.io/trueforge-org/python:3.13.12"
    fi

    if sed --version >/dev/null 2>&1; then
        sed -i \
            -e '\|^LABEL build_version|d' \
            -e '\|^LABEL maintainer|d' \
            -e '\|^ARG BUILD_DATE|d' \
            -e '\|^# syntax=docker/dockerfile:1|d' \
            -e '\|^[[:space:]]*#.*TODO|d' \
            -e '\|^[[:space:]]*#.*Move to our container|d' \
            -e '\|printf "Linuxserver\.io version|d' \
            -e "\|ARG $BUILD_VERSION_ARG|d" \
            -e "s|^FROM ghcr.io/linuxserver/baseimage-alpine[^aA ]*|FROM ${BASE_IMAGE}|g" \
            -e "s|^FROM ghcr.io/linuxserver/baseimage-ubuntu[^aA ]*|FROM ${BASE_IMAGE}|g" \
            -e "s|^FROM ghcr.io/linuxserver/baseimage-debian[^aA ]*|FROM ${BASE_IMAGE}|g" \
            -e "s|^FROM ghcr.io/linuxserver/baseimage-kasmvnc|FROM ghcr.io/trueforge-org/baseimage-kasmvnc|g" \
            -e "s|^FROM ghcr.io/linuxserver/picons-builder|FROM ghcr.io/trueforge-org/picons-builder|g" \
            -e "s|^FROM scratch[^aA ]*|FROM ${BASE_IMAGE}\nARG VERSION|g" \
            -e "s|$BUILD_VERSION_ARG|VERSION|g" \
            -e "\|ADD rootfs.tar.xz|d" \
            -e "s|\${VERSION}|$VERSIONPREFIX\${VERSION}|g" \
            -e 's|amd64|\$TARGETARCH|g' \
            -e 's|x64|\$TARGETARCH|g' \
            -e 's|x86_64|\$TARGETARCH|g' \
            -e 's|arm64|\$TARGETARCH|g' \
            -e 's|aarch64|\$TARGETARCH|g' \
            -e 's|aarch|\$TARGETARCH|g' \
            -e '\|^ARGVERSION|d' \
            -e '\|^ARG DEBIAN_FRONTEND="noninteractive"|d' \
            -e 's|\$TARGETARCHv8-.*^[aA ]*||g' \
            -e 's|COPY.*root.*|USER apps\nCOPY . /\nCOPY ./root /|g' \
            -e 's|ARG VERSION|ARG VERSION\nARG TARGETARCH\nUSER root|g' \
            -e 's|https://wheel-index.linuxserver.io/alpine-3.22/|https://wheel-index.linuxserver.io/ubuntu/|g' \
            -e 's|abc|apps|g' \
            -e 's|/lsiopy|/config/venv|g' \
            "$df"
    else
        sed -i '' \
            -e '\|^LABEL build_version|d' \
            -e '\|^LABEL maintainer|d' \
            -e '\|^ARG BUILD_DATE|d' \
            -e '\|^# syntax=docker/dockerfile:1|d' \
            -e '\|^[[:space:]]*#.*TODO|d' \
            -e '\|^[[:space:]]*#.*Move to our container|d' \
            -e '\|printf "Linuxserver\.io version|d' \
            -e "\|ARG $BUILD_VERSION_ARG|d" \
            -e "\|ADD rootfs.tar.xz|d" \
            -e "s|^FROM ghcr.io/linuxserver/baseimage-alpine[^aA ]*|FROM ${BASE_IMAGE}|g" \
            -e "s|^FROM ghcr.io/linuxserver/baseimage-ubuntu[^aA ]*|FROM ${BASE_IMAGE}|g" \
            -e "s|^FROM ghcr.io/linuxserver/baseimage-debian[^aA ]*|FROM ${BASE_IMAGE}|g" \
            -e "s|^FROM ghcr.io/linuxserver/baseimage-kasmvnc|FROM ghcr.io/trueforge-org/baseimage-kasmvnc|g" \
            -e "s|^FROM ghcr.io/linuxserver/picons-builder|FROM ghcr.io/trueforge-org/picons-builder|g" \
            -e "s|^FROM scratch[^aA ]*|FROM ${BASE_IMAGE}\nARG VERSION|g" \
            -e "s|$BUILD_VERSION_ARG|VERSION|g" \
            -e "s|\${VERSION}|$VERSIONPREFIX\${VERSION}|g" \
            -e 's|amd64|\$TARGETARCH|g' \
            -e 's|x64|\$TARGETARCH|g' \
            -e 's|x86_64|\$TARGETARCH|g' \
            -e 's|arm64|\$TARGETARCH|g' \
            -e 's|aarch64|\$TARGETARCH|g' \
            -e 's|aarch|\$TARGETARCH|g' \
            -e '\|^ARGVERSION|d' \
            -e '\|^ARG DEBIAN_FRONTEND="noninteractive"|d' \
            -e 's|\$TARGETARCHv8-.*^[aA ]*||g' \
            -e 's|COPY.*root.*|USER apps\nCOPY . /\nCOPY ./root /|g' \
            -e 's|ARG VERSION|ARG VERSION\nARG TARGETARCH\nUSER root|g' \
            -e 's|https://wheel-index.linuxserver.io/alpine-3.22/|https://wheel-index.linuxserver.io/ubuntu/|g' \
            -e 's|abc|apps|g' \
            -e 's|/lsiopy|/config/venv|g' \
            "$df"
    fi
    perl -i -pe '
      s/^FROM ghcr\.io\/trueforge-org\/ubuntu[.:][^\s@]+(?:@sha256:[a-f0-9]+)?/FROM ghcr.io\/trueforge-org\/ubuntu:24.04/;
      s/^FROM ghcr\.io\/trueforge-org\/python[.:][^\s@]+(?:@sha256:[a-f0-9]+)?/FROM ghcr.io\/trueforge-org\/python:3.13.12/;
      s/^FROM ghcr\.io\/trueforge-org\/node[.:][^\s@]+(?:@sha256:[a-f0-9]+)?/FROM ghcr.io\/trueforge-org\/node:22.22.0/;
      s/^FROM ghcr\.io\/trueforge-org\/golang[.:][^\s@]+(?:@sha256:[a-f0-9]+)?/FROM ghcr.io\/trueforge-org\/golang:1.26.0/;
      s/^FROM ghcr\.io\/trueforge-org\/postgresql-client[.:][^\s@]+(?:@sha256:[a-f0-9]+)?/FROM ghcr.io\/trueforge-org\/postgresql-client:1.1.0/;
      s/^FROM ghcr\.io\/trueforge-org\/java8(?::[^\s@]+)?(?:@sha256:[a-f0-9]+)?/FROM ghcr.io\/trueforge-org\/java8:8/;
      s/^FROM ghcr\.io\/trueforge-org\/java17(?::[^\s@]+)?(?:@sha256:[a-f0-9]+)?/FROM ghcr.io\/trueforge-org\/java17:17/;
      s/^FROM (ghcr\.io\/trueforge-org\/[^\s@]+)@sha256:[a-f0-9]+/FROM $1/;
    ' "$df"
perl -0777 -i -pe '
  s{
    ^[ \t]*if[^\n]*\{VERSION\+x\}[^\n]*\n   # match the opening line containing {VERSION+x}
    (?:.*\\\n)*?                            # non-greedy match of continuation lines ending with \
    ^[ \t]*fi\b[^\n]*\n                     # match the closing fi line
  }{}mgx
' "$df"
awk 'prev && /^$/ { next } { print } { prev = /\\$/ }' "$df" > "$df.tmp" && mv "$df.tmp" "$df"
if [[ ! -d "$root_folder" ]]; then
    if sed --version >/dev/null 2>&1; then
        sed -i \
        -e 's|COPY.*root.*||g' \
        "$df"
    else
        sed -i '' \
        -e 's|COPY.*root.*||g' \
        "$df"
    fi
fi
if [[ "$CURRENT_BASE" == ghcr.io/trueforge-org/node:* ]]; then
    perl -i -ne 'print unless /^\s*nodejs\s*\\?\s*$/' "$df"
fi
if [[ "$CURRENT_BASE" == ghcr.io/trueforge-org/java*:* ]]; then
    perl -i -ne 'print unless /^\s*(openjdk-[^[:space:]]*|default-jre[^[:space:]]*|default-jdk[^[:space:]]*)\s*\\?\s*$/' "$df"
fi
if sed --version >/dev/null 2>&1; then
    sed -i 's|^USER apps$|USER apps|g' "$df"
else
    sed -i '' 's|^USER apps$|USER apps|g' "$df"
fi
awk '
/^VOLUME[[:space:]]+/ {
    n=split($0, a, /[[:space:]]+/)
    has_config=0
    for (i=2; i<=n; i++) {
        if (a[i] == "/config") {
            has_config=1
        }
    }
    if (has_config && n > 2) {
        print "VOLUME /config"
        for (i=2; i<=n; i++) {
            if (a[i] != "" && a[i] != "/config") {
                print "VOLUME " a[i]
            }
        }
        next
    }
}
{ print }
' "$df" > "$df.tmp" && mv "$df.tmp" "$df"
if ! grep -q '^WORKDIR /config$' "$df"; then
    echo "" >> "$df"
    echo "WORKDIR /config" >> "$df"
fi
if ! grep -Eq '^VOLUME[[:space:]].*([[:space:]]|^)/config([[:space:]]|$)' "$df"; then
    echo "VOLUME /config" >> "$df"
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
echo "[POSTPROCESS] Sanitizing start.sh in $processed"
if [[ ! -f "$processed/start.sh" ]]; then
    template_start="${BASH_SOURCE[0]%/*}/templates/start.sh"
    if [[ -f "$template_start" ]]; then
        cp "$template_start" "$processed/start.sh"
    else
        printf '%s\n' '#!/usr/bin/env bash' > "$processed/start.sh"
    fi
    chmod +x "$processed/start.sh"
fi
if [[ -f "$processed/start.sh" ]]; then
    if sed --version >/dev/null 2>&1; then
        sed -i \
        -e 's|#!/usr/bin/with-contenv.*||g' \
        -e 's|# shellcheck.*||g' \
        -e 's|#!/usr/bin/with-contenv bash||g' \
        -e 's|lsiown.*||g' \
        -e 's|abc|apps|g' \
        -e 's|s6-setuidgid apps||g' \
        -e 's|s6-setuidgid 568||g' \
        -e 's|s6-notifyoncheck.*||g' \
        -e 's|# ===== From.*||g' \
        -e 's|.*LSIO_NON_ROOT_USER.*||g' \
        -e 's|/lsiopy|/config/venv|g' \
        "$processed/start.sh"
    else
        sed -i '' \
        -e 's|#!/usr/bin/with-contenv.*||g' \
        -e 's|# shellcheck.*||g' \
        -e 's|#!/usr/bin/with-contenv bash||g' \
        -e 's|lsiown.*||g' \
        -e 's|abc|apps|g' \
        -e 's|s6-setuidgid apps||g' \
        -e 's|s6-setuidgid 568||g' \
        -e 's|s6-notifyoncheck.*||g' \
        -e 's|# ===== From.*||g' \
        -e 's|.*LSIO_NON_ROOT_USER.*||g' \
        -e 's|/lsiopy|/config/venv|g' \
        "$processed/start.sh"
    fi
    if ! grep -q '^# NONROOT_COMPAT$' "$processed/start.sh"; then
        {
            head -n 1 "$processed/start.sh"
            cat <<'EOF'

EOF
            tail -n +2 "$processed/start.sh"
        } > "$processed/start.sh.tmp" && mv "$processed/start.sh.tmp" "$processed/start.sh"
    fi
fi
done

echo "[POSTPROCESS] Ensuring bash shebangs in .sh files..."
find "$PROCESSED_DIR" -type f -name "*.sh" | while IFS= read -r file; do
    # Strip possible carriage return
    first_line=$(head -n 1 "$file" | tr -d '\r')

    if [[ "$first_line" != "#!"*bash* ]]; then
        echo "Adding bash shebang to $file"
        # Prepend using a temp file
        {
            printf '%s\n' '#!/usr/bin/env bash'
            cat "$file"
        } > "$file.tmp" && mv "$file.tmp" "$file"
    fi

    # ensure its also executable
    chmod +x $file
done
shopt -u nullglob
