# Source: paperless-ngx/paperless-ngx Dockerfile (tag v3.5.1)

Source URL(s) + date: https://raw.githubusercontent.com/paperless-ngx/paperless-ngx/v3.5.1/Dockerfile (fetched 2026-11-27, 9.5 KB; fully read)

## Stages
1. `compile-frontend`: `FROM --platform=$BUILDPLATFORM docker.io/node:24-trixie-slim`; COPY ./src-ui; `corepack enable && pnpm install`; ARG PNGX_TAG_VERSION (dev|beta|fix*|feature* patch environment.prod.ts tag); `./node_modules/.bin/ng build --configuration production`. Output copied to ./documents/static/frontend/ in main-app.
2. `s6-overlay-base`: `FROM ghcr.io/astral-sh/uv:0.13.7-python3.14-trixie-slim@sha256:e80c05a310400cfc90af00b5b7271ef9ad24816e3265e1162af8a678e1aad099`.
   - ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=2, S6_CMD_WAIT_FOR_SERVICES_MAXTIME=0, S6_VERBOSITY=1, PATH=/command:$PATH.
   - ARG S6_OVERLAY_VERSION=3.2.2.0; installs noarch + arch tarball (x86_64 or aarch64) from github just-containers/s6-overlay with sha256 check; build pkgs curl, xz-utils (purged after).
   - COPY ./docker/rootfs /.
3. `main-app` (FROM s6-overlay-base):
   - LABEL authors paperless-ngx team; documentation https://docs.paperless-ngx.com/; source/url github; licenses GPL-3.0-only.
   - ENV PYTHONDONTWRITEBYTECODE=1, PYTHONUNBUFFERED=1, PYTHONWARNINGS=ignore:::django.http.response:517, PNGX_CONTAINERIZED=1, UV_LINK_MODE=copy.
   - ARG JBIG2ENC_VERSION=0.30; downloads jbig2enc deb from https://github.com/paperless-ngx/builder/releases/download/jbig2enc-trixie-v${JBIG2ENC_VERSION}/jbig2enc_${JBIG2ENC_VERSION}-1_${TARGETARCH}.deb.
   - RUNTIME_PACKAGES (apt): curl, gosu, tzdata, fonts-liberation, gettext, ghostscript, gnupg, icc-profiles-free, postgresql-client, mariadb-client, tesseract-ocr (+ eng, deu, fra, ita, spa), unpaper, pngquant, jbig2dec, libxml2, libxslt1.1, qpdf, file, libmagic1, media-types, zlib1g, poppler-utils.
   - Python deps: BUILD_PACKAGES (build-essential, default-libmysqlclient-dev, pkg-config) installed, then `uv export ... > requirements.txt`, `uv pip install --system --no-python-downloads --index https://pypi.org/simple --index https://download.pytorch.org/whl/cpu`; build pkgs purged.
   - COPY ./src -> /usr/src/paperless/src/; frontend copied from compile-frontend.
   - User/group: `paperless` uid 1000 gid 1000, home /usr/src/paperless.
   - Dirs created: /usr/src/paperless/{data,media,consume,export}; .gnupg (700).
   - chmod 1777 /var/cache/fontconfig and /run; chmod u-s /command/s6-overlay-suexec.
   - Build-time: collectstatic (PAPERLESS_SECRET_KEY=build-time-dummy, via s6-setuidgid paperless), compilemessages, deduplicate.py on static.
   - VOLUME ["/usr/src/paperless/data","/usr/src/paperless/media","/usr/src/paperless/consume","/usr/src/paperless/export"].
   - `ENTRYPOINT ["/init"]` (s6-overlay init). No CMD. No USER directive (the image runs root into s6, drops to paperless via s6).
   - `EXPOSE 8000`.
   - HEALTHCHECK interval 30s, timeout 10s, retries 5: `curl -fs -S -L --max-time 2 http://localhost:8000`.

## Env (image)
| Var | Value |
| --- | --- |
| PYTHONDONTWRITEBYTECODE | 1 |
| PYTHONUNBUFFERED | 1 |
| PNGX_CONTAINERIZED | 1 |
| UV_LINK_MODE | copy |
| S6_* | see above |

## Gotchas
- Upstream Dockerfile is NOT read verbatim in plan.md (plan says it was read via WebFetch summary); this is the verbatim file.
- Upstream image ships s6-overlay and gosu; plan replaces s6 with `USER apps` and `CMD ["/start.sh"]`.
- Paths: /usr/src/paperless/data etc. are VOLUME in upstream.
- jbig2enc comes from paperless-ngx/builder releases (not fetched).
