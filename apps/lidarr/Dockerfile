

FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:91d978bcece60398d9a21a2f331801d9004f5651a323f8f25ed2fa70b5d8eacd
ARG TARGETARCH
ARG VENDOR
ARG VERSION

ENV DOTNET_EnableDiagnostics=0 \
    LIDARR__UPDATE__BRANCH=plugins

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
    chown -R root:root /app && chmod -R 755 /app && \
    rm -rf /var/lib/apt/lists/* /tmp/* /app/bin/Lidarr.Update /app/bin/fpcalc

COPY . /

USER apps:apps
WORKDIR /config
