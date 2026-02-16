# Downstream Changes

Base image version: `3.14.3`

This update changes Python base-image runtime behavior to align with container policy:

- The image no longer creates `/config/venv` as a symlink during build.
- The bundled runtime venv path is `${VENV_FOLDER}` at `/apps/venv`.
- The image restores `/config/venv` from `/apps/venv` at runtime when `/config/venv` is missing or empty.
- Final runtime user is `apps`.

## Affected downstream containers and required changes

For each path below, required change is:

- **Required change:** No Dockerfile change required.
- **Runtime expectation change:** Do not rely on `/config/venv` being a symlink. Base image now provides a built-in venv at `/apps/venv` and restores `/config/venv` from it when `/config/venv` is missing/empty. Keep ephemeral caches/scratch data in `/tmp`.

Affected paths:

- `apps/apprise-api/Dockerfile`
- `apps/balfolk-ics/Dockerfile`
- `apps/bazarr/Dockerfile`
- `apps/calibre-web/Dockerfile`
- `apps/deluge/Dockerfile`
- `apps/devcontainer/Dockerfile`
- `apps/esphome/Dockerfile`
- `apps/faster-whisper/Dockerfile`
- `apps/go-yq/Dockerfile`
- `apps/home-assistant/Dockerfile`
- `apps/jbops/Dockerfile`
- `apps/k8s-sidecar/Dockerfile` (builder + runtime stages)
- `apps/kometa/Dockerfile`
- `apps/lazylibrarian/Dockerfile`
- `apps/medusa/Dockerfile`
- `apps/nzbget/Dockerfile`
- `apps/piper/Dockerfile`
- `apps/pyload-ng/Dockerfile`
- `apps/python-node/Dockerfile`
- `apps/qbitmanage/Dockerfile`
- `apps/qbittorrent/Dockerfile`
- `apps/sabnzbd/Dockerfile`
- `apps/tautulli/Dockerfile`
- `apps/theme-park/Dockerfile` (builder stage)
- `apps/transmission/Dockerfile`
- `apps/webhook/Dockerfile`
- `apps/yq/Dockerfile`
