# Initial draft from plan.md. UNVERIFIED items are marked inline.

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a AS build
ARG VERSION
ARG TARGETARCH
# sha256 of the v${VERSION} source tarball. Not published upstream: compute it once and pin it before the first build.
# Empty on purpose, so the build fails closed until it is set (UNVERIFIED value).
ARG SOURCE_SHA256=
USER root

ENV DOTNET_CLI_HOME=/tmp \
    DOTNET_CLI_TELEMETRY_OPTOUT=1 \
    DOTNET_NOLOGO=1 \
    NUGET_PACKAGES=/tmp/nuget

# .NET SDK 8.0 is installed to /tmp for the build only. Package names libicu78 and p7zip-full are UNVERIFIED on 26.04.
# curl may already be in the base; apt is idempotent either way.
RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        libicu78 \
        p7zip-full \
    && rm -rf /var/lib/apt/lists/* \
    && curl -fsSL -o /tmp/dotnet-install.sh https://dot.net/v1/dotnet-install.sh \
    && chmod +x /tmp/dotnet-install.sh \
    && /tmp/dotnet-install.sh -c 8.0 --install-dir /tmp/dotnet-sdk

RUN mkdir -p /tmp/src \
 && curl -fsSL -o /tmp/src.tar.gz "https://github.com/gaseous-project/gaseous-server/archive/refs/tags/${VERSION}.tar.gz" \
 && echo "${SOURCE_SHA256}  /tmp/src.tar.gz" | sha256sum -c - \
 && tar xzf /tmp/src.tar.gz -C /tmp/src --strip-components=1 \
 && rm -f /tmp/src.tar.gz

# EmulatorJS goes into wwwroot before publish, as upstream does after publish.
# No published checksum (UNVERIFIED). Archive root and whether it ships a license are UNVERIFIED.
RUN curl -fsSL -o /tmp/4.2.1.7z https://cdn.emulatorjs.org/releases/4.2.1.7z \
 && mkdir -p /tmp/src/gaseous-server/wwwroot/emulators \
 && 7z x /tmp/4.2.1.7z -o/tmp/src/gaseous-server/wwwroot/emulators/ \
 && rm -f /tmp/4.2.1.7z

# .NET uses its own RIDs (x64, not amd64). Self-contained publish, so the runtime is not installed in the final stage.
RUN case "${TARGETARCH}" in \
        amd64) RID=linux-x64 ;; \
        arm64) RID=linux-arm64 ;; \
        *) echo "unsupported ${TARGETARCH}" >&2; exit 1 ;; \
    esac \
 && export PATH=/tmp/dotnet-sdk:$PATH \
 && cd /tmp/src/gaseous-server \
 && dotnet publish gaseous-server.csproj -c Release -r "${RID}" --self-contained true -o /tmp/out

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a
USER root

# ICU is needed by the .NET runtime (UNVERIFIED whether this app needs it; check the startup log).
RUN apt-get update && apt-get install -y --no-install-recommends libicu78 \
    && rm -rf /var/lib/apt/lists/*

COPY --from=build /tmp/out/ /app/gaseous-server/
COPY --from=build /tmp/src/LICENSE /usr/share/licenses/gaseous-server/LICENSE
RUN chown -R root:root /app/gaseous-server && chmod -R 0755 /app/gaseous-server

ENV INDOCKER=1 \
    HOME=/config \
    ASPNETCORE_URLS=http://+:5198

# Upstream HEALTHCHECK (port 80) is not carried over. Port 5198 is used because user apps cannot bind port 80.
USER apps
COPY --chmod=0755 . /

WORKDIR /app/gaseous-server
EXPOSE 5198
VOLUME ["/config"]
