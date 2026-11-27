FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a AS build

ARG VERSION
ARG TARGETARCH
USER root

RUN echo "*** Installing build packages ***" && \
  apt-get update && \
  apt-get install -y --no-install-recommends unzip && \
  rm -rf /var/lib/apt/lists/*

# Per-arch SHA-256 values come from the GitHub release asset digests (plan section 1).
RUN echo "*** Installing SteamPrefill ${VERSION} ***" && \
  case "${TARGETARCH}" in \
    amd64) ARCH=x64; SHA256=974d7c4e5c7a4664bd23cc8f1bba3db354ecb465a2cfc442ba766b048160394d ;; \
    arm64) ARCH=arm64; SHA256=018330d6f2a2135e6b526662ccb39b54e878d2ae7bebcdc185386b220328f7be ;; \
    *) echo "unsupported arch ${TARGETARCH}" && exit 1 ;; \
  esac && \
  curl -fsSL -o /tmp/steamprefill.zip \
    "https://github.com/tpill90/steam-lancache-prefill/releases/download/v${VERSION}/SteamPrefill-${VERSION}-linux-${ARCH}.zip" && \
  echo "${SHA256}  /tmp/steamprefill.zip" | sha256sum -c - && \
  mkdir -p /app/steamprefill && \
  unzip -o /tmp/steamprefill.zip -d /app/steamprefill && \
  chmod 0755 /app/steamprefill/SteamPrefill && \
  rm /tmp/steamprefill.zip

# UNVERIFIED: the license path inside the zip is not known, so the upstream LICENSE is fetched from the tag.
RUN mkdir -p /usr/share/licenses/lancache-monolithic && \
  curl -fsSL -o /usr/share/licenses/lancache-monolithic/LICENSE \
    "https://raw.githubusercontent.com/tpill90/steam-lancache-prefill/v${VERSION}/LICENSE"

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
USER root

ENV \
  HOME=/tmp \
  TZ=Etc/UTC

COPY --from=build /app/steamprefill/ /app/steamprefill/
COPY --from=build /usr/share/licenses/lancache-monolithic/ /usr/share/licenses/lancache-monolithic/

RUN chown -R apps:apps /app && chmod -R 755 /app

USER apps
COPY --chmod=0755 . /

VOLUME /config
