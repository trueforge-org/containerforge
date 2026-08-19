

FROM ghcr.io/trueforge-org/ubuntu:26.4@sha256:a1011d7c17be3f647e02872e2cdfe59154fb145297e1b5ceaba30341fcda262e
ARG TARGETARCH
ARG VENDOR
ARG VERSION

ENV DOTNET_EnableDiagnostics=0 \
    WHISPARR__UPDATE__BRANCH=eros \
    WHISPARR__SERVER__PORT=6969

USER root
WORKDIR /app

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        sqlite3 \
    && \
    mkdir -p /app/bin && \
    curl -fsSL "https://github.com/Whisparr/whisparr-eros/releases/download/v${VERSION}/Whisparr.eros.${VERSION}.linux-${TARGETARCH/amd64/x64}.tar.gz" \
        | tar xzf - -C /app/bin --strip-components=1 && \
    printf "UpdateMethod=docker\nBranch=%s\nPackageVersion=%s\nPackageAuthor=[%s](https://github.com/%s)\n" \
        "${WHISPARR__UPDATE__BRANCH}" "${VERSION}" "${VENDOR}" "${VENDOR}" > /app/package_info && \
    chown -R root:root /app && chmod -R 755 /app && \
    rm -rf /var/lib/apt/lists/* /tmp/* /app/bin/Whisparr.Update


USER apps
COPY --chmod=0755 . /
WORKDIR /config

