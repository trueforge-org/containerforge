

FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:654a659958d368fa2e5f1aca4a24347c3e58f2c9c5194e1d07e3abaeb539ac32
ARG TARGETARCH
ARG VENDOR
ARG VERSION

ENV DOTNET_EnableDiagnostics=0 \
    RADARR__UPDATE__BRANCH=develop \
    RADARR__SERVER__PORT=7878

USER root
WORKDIR /app

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        sqlite3 \
    && \
    mkdir -p /app/bin && \
    curl -fsSL "https://radarr.servarr.com/v1/update/${RADARR__UPDATE__BRANCH}/updatefile?version=${VERSION}&os=linux&runtime=netcore&arch=${TARGETARCH/amd64/x64}" \
        | tar xzf - -C /app/bin --strip-components=1 && \
    printf "UpdateMethod=docker\nBranch=%s\nPackageVersion=%s\nPackageAuthor=[%s](https://github.com/%s)\n" \
        "${RADARR__UPDATE__BRANCH}" "${VERSION}" "${VENDOR}" "${VENDOR}" > /app/package_info && \
    chown -R root:root /app && chmod -R 755 /app && \
    rm -rf /var/lib/apt/lists/* /tmp/* /app/bin/Radarr.Update


USER apps
COPY --chmod=0755 . /
WORKDIR /config

