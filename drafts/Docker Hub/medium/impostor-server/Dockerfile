FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH

ENV DOTNET_ROOT=/usr/lib/dotnet \
    DOTNET_EnableDiagnostics=0 \
    DOTNET_BUNDLE_EXTRACT_BASE_DIR=/tmp/dotnet-bundle \
    DOTNET_CLI_HOME=/tmp \
    ASPNETCORE_URLS=

USER root
WORKDIR /app

# The runtime package is versioned by .NET (10.0.x), not by VERSION, so it is not pinned to VERSION.
# UNVERIFIED: install path (/usr/lib/dotnet) and whether ICU is needed (else set DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1).
RUN apt-get update && apt-get install -y --no-install-recommends \
        aspnetcore-runtime-10.0 \
    && rm -rf /var/lib/apt/lists/*

# The release tarball is framework-dependent (no runtimeconfig.json), so it needs the apt runtime above.
# Hashes are the GitHub release asset digests for 1.10.10; refresh them when VERSION changes.
RUN case "${TARGETARCH}" in \
      amd64) ARCH=x64;   SHA256=39362bc4fe5f09098fb60140be8ea55ca05a4c020a06a2a6e594269b71b0905d ;; \
      arm64) ARCH=arm64; SHA256=9af6f001135fb5b94746f8131fa4eba8d0dc80cfa19d593d743c96a7efeb4b0a ;; \
      *) echo "unsupported arch: ${TARGETARCH}" >&2; exit 1 ;; \
    esac \
    && curl -fsSL -o /tmp/impostor.tar.gz "https://github.com/AeonLucid/Impostor/releases/download/v${VERSION}/Impostor-Server_${VERSION}_linux-${ARCH}.tar.gz" \
    && echo "${SHA256}  /tmp/impostor.tar.gz" | sha256sum -c - \
    && mkdir -p /app /defaults /usr/share/licenses/impostor-server \
    && tar -xzf /tmp/impostor.tar.gz -C /app \
    && mv /app/config.json /defaults/config.json \
    && curl -fsSL -o /usr/share/licenses/impostor-server/LICENSE "https://raw.githubusercontent.com/AeonLucid/Impostor/v${VERSION}/LICENSE" \
    && rm -f /tmp/impostor.tar.gz \
    && chmod 755 /app/Impostor.Server \
    && chown -R root:root /app /defaults /usr/share/licenses/impostor-server \
    && chmod -R 755 /app /defaults

USER apps
COPY --chmod=0755 . /

# UDP carries game traffic; TCP serves HTTP matchmaking on the same port.
EXPOSE 22023/tcp 22023/udp
VOLUME /config
WORKDIR /config
