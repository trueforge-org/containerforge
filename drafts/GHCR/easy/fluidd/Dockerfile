FROM ghcr.io/trueforge-org/nginx:1.28.3@sha256:1e4f20bfcf614853820179bb28127b1375061c09f565bb7010495845d4742c9f

ARG VERSION
# sha256 of fluidd.zip from the GitHub release asset digest (checked against the API on 2026-11-25)
ARG FLUIDD_SHA256="eea2b7e95dbe4b1ddec4fc97547a36fd8aeac411070ad86f6cd77d67ddb57bc6"

USER root

# Static dist from the release zip. curl and unzip come from the ubuntu base.
# UNVERIFIED: the zip layout (top-level index.html or a dist/ folder) is checked at build time.
RUN set -eux; \
    curl -fsSL -o /tmp/fluidd.zip "https://github.com/fluidd-core/fluidd/releases/download/v${VERSION}/fluidd.zip"; \
    echo "${FLUIDD_SHA256}  /tmp/fluidd.zip" | sha256sum -c -; \
    mkdir -p /tmp/fluidd-src /usr/share/nginx/html /usr/share/licenses/fluidd; \
    unzip -q /tmp/fluidd.zip -d /tmp/fluidd-src; \
    src=/tmp/fluidd-src; \
    if [ -d /tmp/fluidd-src/dist ]; then src=/tmp/fluidd-src/dist; fi; \
    cp -a "${src}/." /usr/share/nginx/html/; \
    curl -fsSL -o /usr/share/licenses/fluidd/LICENSE "https://raw.githubusercontent.com/fluidd-core/fluidd/v${VERSION}/LICENSE"; \
    rm -rf /tmp/fluidd-src /tmp/fluidd.zip

EXPOSE 8080

USER apps
COPY --chmod=0755 . /
