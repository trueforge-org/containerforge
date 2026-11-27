
FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5

ARG VERSION
ARG TARGETARCH

# renovate: datasource=github-releases depName=aptible/supercronic versioning=semver
ARG SUPERCRONIC_VERSION=0.2.51
# renovate: datasource=npm depName=playwright
ARG PLAYWRIGHT_VERSION=1.65.1

ENV PLAYWRIGHT_BROWSERS_PATH=/app/browsers \
    PUPPETEER_SKIP_DOWNLOAD=1 \
    PUPPETEER_EXECUTABLE_PATH=/usr/local/bin/chromium \
    YARN_CACHE_FOLDER=/tmp/.yarn \
    TMPDIR=/tmp \
    HOME=/tmp \
    EXPORT_PATH=/config/export

USER root

# fetch the upstream script, install its locked JS dependencies
# UNVERIFIED: whether yarn is present in the base image; otherwise npm installs it
RUN mkdir -p /app /usr/share/licenses/breitbandmessung-de \
 && curl -fsSL "https://github.com/shneezin/breitbandmessung-node/archive/${VERSION}.tar.gz" \
      | tar xz -C /app --strip-components=1 \
 && cd /app \
 && (command -v yarn >/dev/null || npm install -g yarn) \
 && yarn install --frozen-lockfile --production \
 && rm -rf /tmp/.yarn

# headless Chromium from Playwright, plus its apt libraries
# UNVERIFIED: Playwright on Ubuntu 26.04 and Puppeteer 19 compatibility with this Chromium build
RUN npx --yes "playwright@${PLAYWRIGHT_VERSION}" install --with-deps chromium \
 && ln -s "$(find /app/browsers -type f -name chrome -path '*chrome-linux*' | head -n1)" /usr/local/bin/chromium

# supercronic for scheduled runs
# UNVERIFIED: arm64 sha1 is not recorded yet; the build fails closed until it is added
RUN case "${TARGETARCH}" in \
      amd64) SUPERCRONIC_SHA1=1692066e350a88ff4d7d6474fe3c7a6c41ec5e89 ;; \
      *) echo "supercronic sha1 not recorded for ${TARGETARCH}" >&2; exit 1 ;; \
    esac \
 && curl -fsSL -o /usr/local/bin/supercronic \
      "https://github.com/aptible/supercronic/releases/download/v${SUPERCRONIC_VERSION}/supercronic-linux-${TARGETARCH}" \
 && echo "${SUPERCRONIC_SHA1}  /usr/local/bin/supercronic" | sha1sum -c - \
 && chmod 755 /usr/local/bin/supercronic

RUN printf '%s\n' \
      "breitbandmessung-node (${VERSION}): MIT, per package.json (no LICENSE file upstream)" \
      "supercronic ${SUPERCRONIC_VERSION}: MIT" \
      "Chromium: see the notices shipped with the Playwright browser install" \
      > /usr/share/licenses/breitbandmessung-de/NOTICE \
 && chown -R root:root /app /usr/share/licenses/breitbandmessung-de \
 && chmod -R 755 /app /usr/share/licenses/breitbandmessung-de \
 && rm -rf /tmp/* /var/lib/apt/lists/*

# run as 568
USER apps
COPY --chmod=0755 . /

WORKDIR /app
VOLUME /config
