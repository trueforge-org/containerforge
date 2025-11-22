

FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:435d3cfa071624ce5e12c531ede975f9ba55b0acd5b5d20c3f8e082a745b639e
ARG TARGETARCH
ARG VENDOR
ARG VERSION

ENV DOTNET_EnableDiagnostics=0 \
    LIDARR__UPDATE__BRANCH=plugins \
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
    curl -fsSL "https://github.com/acoustid/chromaprint/releases/download/v${FPCALC_VERSION}/chromaprint-fpcalc-1.6.0-linux-${FPCALC_ARCH}.tar.gz" \
        | tar xzf - -C /app/bin --strip-components=1 && \
    cp /app/bin/fpcalc /usr/local/bin/fpcalc && \
    printf "UpdateMethod=docker\nBranch=%s\nPackageVersion=%s\nPackageAuthor=[%s](https://github.com/%s)\n" \
        "${LIDARR__UPDATE__BRANCH}" "${VERSION}" "${VENDOR}" "${VENDOR}" > /app/package_info && \
    ln -s $(which ffprobe) /app/bin/ffprobe && \
    chown -R root:root /app && chmod -R 755 /app && \
    rm -rf /var/lib/apt/lists/* /tmp/* /app/bin/Lidarr.Update /app/bin/fpcalc

COPY . /

USER apps:apps
WORKDIR /config

HEALTHCHECK CMD curl --connect-timeout 15 --max-time 100 --silent --show-error --fail "http://localhost:${LIDARR__SERVER__PORT}/"
