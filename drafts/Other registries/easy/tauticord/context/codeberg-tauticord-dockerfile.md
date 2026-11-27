# nwithan8/tauticord Dockerfile at tag 6.2.0

## Source URL(s) + date
- https://codeberg.org/nwithan8/tauticord/raw/tag/6.2.0/Dockerfile (fetched 2026-11-27)

## Build
- `FROM nwithan8/python-node-alpine:04152026_1` (Docker Hub image; Node.js 18.19 and Python 3.11.x on Alpine 3.19 per comment).
- `WORKDIR /app`.
- Python venv already in base image at `/app/venv`.
- `COPY requirements.txt requirements.txt` then:
  - `/app/venv/bin/pip install --no-cache-dir setuptools_rust` (with `LIBRARY_PATH=/lib:/usr/lib`).
  - `/app/venv/bin/pip install --no-cache-dir -r requirements.txt --prefer-binary` (same env).
- `VOLUME /config`, `VOLUME /logs`.
- `COPY . .`.
- `EXPOSE 8283` (API / webhook).
- `RUN echo "**** removing unneeded files ****"` (no actual deletion commands).
- `ENTRYPOINT ["sh", "entrypoint.sh"]`.

## Release 6.2.0
- Published 2026-11-14 (API). Tag 6.2.0, target master.
- Notes: adds Tautulli v2.19.x support; drops Tautulli v2.18.x and earlier.
- Release assets: none (only source archives: tarball/zipball URLs under codeberg archive path).

## License
- GPL-3.0 (LICENSE fetched from Codeberg API raw, GNU GPL v3 text).

## Failures / notes
- Codeberg release HTML page (https://codeberg.org/nwithan8/tauticord/releases/tag/6.2.0) returned an anti-bot interstitial, no content.

## Gotchas
- Base image is a Docker Hub image, pinned by date tag `04152026_1`; version not verified against Docker Hub (not in URL list).
- Entrypoint is `entrypoint.sh` (not fetched).
