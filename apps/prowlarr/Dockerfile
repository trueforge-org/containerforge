

FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:6b8f2bf1ddc52dd7a9a640e325492250ff9de736440271fde15505decbd88626
ARG TARGETARCH
ARG VENDOR
ARG VERSION

ENV DOTNET_EnableDiagnostics=0 \
    PROWLARR__UPDATE__BRANCH=develop

USER root
WORKDIR /app

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        sqlite3 \
    && \
    mkdir -p /app/bin && \
    curl -fsSL "https://prowlarr.servarr.com/v1/update/${PROWLARR__UPDATE__BRANCH}/updatefile?version=${VERSION}&os=linux&runtime=netcore&arch=${TARGETARCH/amd64/x64}" \
        | tar xzf - -C /app/bin --strip-components=1 && \
    printf "UpdateMethod=docker\nBranch=%s\nPackageVersion=%s\nPackageAuthor=[%s](https://github.com/%s)\n" \
        "${PROWLARR__UPDATE__BRANCH}" "${VERSION}" "${VENDOR}" "${VENDOR}" > /app/package_info && \
    chown -R root:root /app && chmod -R 755 /app && \
    rm -rf /var/lib/apt/lists/* /tmp/* /app/bin/Prowlarr.Update

COPY . /

USER apps:apps
WORKDIR /config
