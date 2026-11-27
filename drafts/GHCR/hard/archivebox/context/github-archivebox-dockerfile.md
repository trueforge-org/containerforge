# ArchiveBox upstream Dockerfile (commit 289d6a5904642b02c618e77f225aa28bd201a145)

Source URL(s) + date: https://raw.githubusercontent.com/ArchiveBox/ArchiveBox/289d6a5904642b02c618e77f225aa28bd201a145/Dockerfile ; release https://github.com/ArchiveBox/ArchiveBox/releases/latest (redirect) ; fetched 2026-11-27

## Version / release
- Latest release tag `v0.9.77` (redirect Location `releases/tag/v0.9.77`). api.github.com call returned 403 (rate limit); the HTML redirect was used as the one alternative.

## Structure (multi-stage, abx-dl based)
- `ARG ABX_DL_IMAGE=archivebox/abx-dl:main` (base runtime image, owns Python, Node, Chromium, extractor deps).
- `FROM archivebox/sonic:1.4.9 AS sonic` (search backend binary source).
- `FROM ${ABX_DL_IMAGE} AS archivebox-runtime-base` -> `archivebox-builder` -> final stage (`FROM archivebox-builder`).
- Build as the upstream "multistage" approach: consumes abx-dl image; Python venv at /venv extended with `uv pip install --no-deps $CODE_DIR`.
- Build needs the abx-dl image: `docker buildx build ../abx-dl ...` then `--build-arg ABX_DL_IMAGE=archivebox/abx-dl:dev`.
- Final stage runs `archivebox install` and `archivebox version` as UID 911 via setpriv; installs all plugins in catalog (incl. disabled server plugins).
- Upstream size budget comment: 1025 MiB compressed.

## Env (Dockerfile ENV)
| Env | Value |
| --- | --- |
| TZ | UTC |
| LANG / LC_ALL | C.UTF-8 |
| PYTHON_VERSION | 3.13 |
| NODE_VERSION | 24 |
| ARCHIVEBOX_USER | archivebox |
| DEFAULT_ARCHIVEBOX_UID / GID | 911 / 911 |
| IN_DOCKER | True |
| CODE_DIR | /app |
| DATA_DIR | /data |
| CONFIG_DIR | /opt/archivebox |
| ABXPKG_LIB_DIR | /opt/archivebox/lib |
| PLAYWRIGHT_BROWSERS_PATH | /opt/archivebox/lib/playwright/cache |
| PERSONAS_DIR | /data/personas |
| CHROME_HEADLESS | true |
| CHROME_SANDBOX | false |
| CHROME_ISOLATION | crawl |
| TMP_DIR | /tmp/archivebox |
| HOME | /home/archivebox |
| XDG_CONFIG_HOME | /home/archivebox/.config |
| XDG_CACHE_HOME | /opt/archivebox/lib/cache |
| TIMEOUT | 600 |
| UV_PROJECT_ENVIRONMENT / VIRTUAL_ENV | /venv |
| PATH | /venv/bin:/opt/node/bin:$PATH |
| GOOGLE_API_KEY / GOOGLE_DEFAULT_CLIENT_ID / GOOGLE_DEFAULT_CLIENT_SECRET | `no` |

## Runtime
- Entry: `ENTRYPOINT ["dumb-init", "--", "/app/bin/docker_entrypoint.sh"]`
- `CMD ["archivebox", "server", "--init", "0.0.0.0:5797"]`
- `WORKDIR $DATA_DIR`, `VOLUME $DATA_DIR`, `EXPOSE 5797`.
- HEALTHCHECK: `--interval=30s --timeout=20s --retries=15`, `curl --fail ... 'http://admin.archivebox.localhost:5797/health/' | grep -q 'OK'`.
- Image init: `archivebox init` at build, chown of data/config dirs to 911:911; `chmod g+w` on TMP_DIR, ABXPKG_LIB_DIR, PLAYWRIGHT_BROWSERS_PATH.

## User/UID
- Runtime user `archivebox`, UID/GID 911 (DEFAULT_ARCHIVEBOX_UID/GID). Final stage verifies `setpriv --reuid=archivebox`.

## Gotchas
- Dockerfile asserts no gcc/g++/make in runtime (`abxpkg load --binproviders=env`).
- Upstream says never run verification as root, and no sudo/downloads at runtime; plugin deps must be in the image.
- Image depends on archivebox/abx-dl (external, not in this repo); its tag is required to build.
