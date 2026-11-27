# syntax=docker/dockerfile:1@sha256:572cebbc2b15e6f84c077742952674889cb63cd5e9b80abdffcbe587b6f19183
# UNVERIFIED: the SDK build stage is not digest-pinned yet (resolve and pin at implementation).
FROM --platform=$BUILDPLATFORM mcr.microsoft.com/dotnet/sdk:9.0@sha256:1dfdb27e9c2c345cb598925ccf6b13719ecfebea8467bd4745c23a3c108cdf84 AS build

ARG VERSION
ARG TARGETARCH
ENV DOTNET_CLI_TELEMETRY_OPTOUT=1 \
    DOTNET_NOLOGO=1 \
    NUGET_PACKAGES=/tmp/nuget \
    HOME=/tmp

WORKDIR /src
# Upstream publishes no checksum for the source tarball. The tag is fetched over HTTPS.
RUN set -eux; \
    case "${TARGETARCH}" in \
      amd64) RID=linux-x64 ;; \
      arm64) RID=linux-arm64 ;; \
      *) echo "unsupported TARGETARCH: ${TARGETARCH}" >&2; exit 1 ;; \
    esac; \
    curl -fsSL "https://github.com/iPromKnight/zilean/archive/refs/tags/v${VERSION}.tar.gz" | tar xz -C /src --strip-components=1; \
    dotnet restore -r "${RID}"; \
    (cd src/Zilean.ApiService && dotnet publish -c Release --no-restore -r "${RID}" --self-contained true -o /out); \
    (cd src/Zilean.Scraper && dotnet publish -c Release --no-restore -r "${RID}" --self-contained true -o /out)

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

ARG VERSION

ENV DOTNET_RUNNING_IN_CONTAINER=true \
    DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=false \
    DOTNET_BUNDLE_EXTRACT_BASE_DIR=/tmp/dotnet \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONPYCACHEPREFIX=/tmp/pycache \
    ASPNETCORE_URLS=http://+:8181 \
    HOME=/tmp

USER root
WORKDIR /app

COPY --from=build /out /app
COPY --from=build /src/requirements.txt /tmp/requirements.txt

# UNVERIFIED: the libpython shared library package name for Ubuntu 26.04 and the pinned pip packages (loguru, rich, rank-torrent-name) install.
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        python3 \
        python3-pip \
        libpython3-stdlib && \
    pip3 install --no-cache-dir --break-system-packages --target /app/python -r /tmp/requirements.txt && \
    python3 -c 'import os, sysconfig, sys; sys.exit(0 if os.path.isfile(os.path.join(sysconfig.get_config_var("LIBDIR"), sysconfig.get_config_var("INSTSONAME"))) else 1)' && \
    rm -rf /app/data && ln -s /config /app/data && \
    mkdir -p /usr/share/licenses/zilean && \
    printf '%s\n' "Zilean ${VERSION}" "Source: https://github.com/iPromKnight/zilean" "License: not stated in the upstream repository (UNVERIFIED, see docker-bake.hcl)." > /usr/share/licenses/zilean/NOTICE && \
    chown -R root:root /app && chmod -R a+rX /app && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/*

USER apps
COPY --chmod=0755 . /

EXPOSE 8181
VOLUME /config
WORKDIR /app
CMD ["/start.sh"]
