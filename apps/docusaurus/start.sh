#!/usr/bin/env bash
set -euo pipefail

msg() {
    echo "[docusaurus] $*"
}

DOCU_PATH="/config"
SITE_PATH="${DOCU_PATH}/${WEBSITE_NAME}"
WEB_SRC_PATH="${DOCU_PATH}/website"

# HOME in the base image lives under /app, which is read-only at runtime
export HOME="/tmp/home"
mkdir -p "${HOME}"

if [[ -z "${WEBSITE_NAME}" ]]; then
    msg "WEBSITE_NAME must not be empty"
    exit 1
fi

if [[ ! -d "${SITE_PATH}" ]]; then
    msg "Creating new site '${WEBSITE_NAME}' from template '${TEMPLATE}'..."
    cd "${DOCU_PATH}"
    /app/create-docusaurus/node_modules/.bin/create-docusaurus \
        "${WEBSITE_NAME}" "${TEMPLATE}" \
        --package-manager npm \
        --javascript \
        --skip-install
else
    msg "Using existing site in ${SITE_PATH}"
fi

# Keep the /config/website symlink from the previous image layout
ln -sfn "${SITE_PATH}" "${WEB_SRC_PATH}"

cd "${SITE_PATH}"

# Sites created by the previous (yarn-based) image keep using yarn
if [[ -f yarn.lock ]]; then
    PM="yarn"
else
    PM="npm"
fi

if [[ ! -d node_modules ]] || [[ "${AUTO_UPDATE}" == "true" ]]; then
    msg "Installing dependencies with ${PM}..."
    if [[ "${PM}" == "yarn" ]]; then
        yarn install --non-interactive
    else
        npm install --no-fund --no-audit
    fi
fi

SERVE_ARGS=(--port "${DOCUSAURUS_PORT}" --host 0.0.0.0 --no-open)

case "${RUN_MODE}" in
    development)
        msg "Starting development server on port ${DOCUSAURUS_PORT}..."
        if [[ "${PM}" == "yarn" ]]; then
            exec yarn run start "${SERVE_ARGS[@]}"
        fi
        exec npm run start -- "${SERVE_ARGS[@]}"
        ;;
    production)
        msg "Building and serving production site on port ${DOCUSAURUS_PORT}..."
        if [[ "${PM}" == "yarn" ]]; then
            yarn run build
            exec yarn run serve "${SERVE_ARGS[@]}"
        fi
        npm run build
        exec npm run serve -- "${SERVE_ARGS[@]}"
        ;;
    *)
        msg "Running custom script '${RUN_MODE}'..."
        if [[ "${PM}" == "yarn" ]]; then
            exec yarn run "${RUN_MODE}"
        fi
        exec npm run "${RUN_MODE}"
        ;;
esac
