#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

if [[ -d "apps/${1}" ]]; then
    echo "Start processing apps/${1} ..."
    app="apps/${1}"
    appname=$(basename "apps/${1}")
    appversion=$(grep -A1 'variable "VERSION"' "${app}/docker-bake.hcl" | grep 'default' | sed 's/.*"\(.*\)".*/\1/')

    # Ensure to start with a clean slate
    rm -rf "${app}/app-changelog.md" || echo "changelog not found..."

    echo "Generating changelogs for: ${appname}"
    # Changelog containing only last change
    git-chglog --next-tag "${appname}-${appversion}" \
        --tag-filter-pattern "^${appname}-\d+\.\d+\.\d+\$" \
        --path "${app}" \
        -o "${app}/app-changelog.md" \
        "${appname}-${appversion}" || echo "changelog generation failed..."
else
    echo "App 'apps/${1}' no longer exists in repo. Skipping it..."
fi
echo "Done processing apps/${1} ..."
