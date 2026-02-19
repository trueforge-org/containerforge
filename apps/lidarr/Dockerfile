

FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:a42a7b2fe3c044339769eca34c011337ec5ecdbb7ff3c2af30bc9105afb035b8
ARG TARGETARCH
ARG VENDOR
ARG VERSION

ENV DOTNET_EnableDiagnostics=0 \
    LIDARR__UPDATE__BRANCH=develop \
    LIDARR__SERVER__PORT=8686

ARG FPCALC_ARCH=${TARGETARCH/arm64/arm64}
ARG FPCALC_ARCH=${TARGETARCH/amd64/x86_64}
ARG FPCALC_VERSION=1.6.0

USER root
WORKDIR /app

# TODO readd chromaprint
RUN add-apt-repository universe && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        ffmpeg \
        sqlite3 \
        xmlstarlet \
    && \
    mkdir -p /app/bin && \
    curl -fsSL "https://lidarr.servarr.com/v1/update/${LIDARR__UPDATE__BRANCH}/updatefile?version=${VERSION}&os=linux&runtime=netcore&arch=${TARGETARCH/amd64/x64}" \
        | tar xzf - -C /app/bin --strip-components=1 && \
    printf "UpdateMethod=docker\nBranch=%s\nPackageVersion=%s\nPackageAuthor=[%s](https://github.com/%s)\n" \
        "${LIDARR__UPDATE__BRANCH}" "${VERSION}" "${VENDOR}" "${VENDOR}" > /app/package_info && \
    ln -s $(which ffprobe) /app/bin/ffprobe && \
    chown -R apps:apps /app && chmod -R 755 /app

COPY . /

COPY container-test.yaml /container-test.yaml
USER apps
WORKDIR /config

HEALTHCHECK CMD curl --connect-timeout 15 --max-time 100 --silent --show-error --fail "http://localhost:${LIDARR__SERVER__PORT}/"
