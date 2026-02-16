## TODO: also make go-yq container
FROM ghcr.io/trueforge-org/python:3.13.12@sha256:00750811fb5c6481942d0f9903fa012e5c221ebb8ddd261024fb72fecf456429

# set version label
ARG VERSION
ARG TARGETARCH
USER root

RUN echo "*** Installing go-yq ***" && \
    mkdir -p /app && \
    curl -L -o /app/yq \
        "https://github.com/mikefarah/yq/releases/download/v${VERSION}/yq_linux_${TARGETARCH}" && \
    chmod 755 /app/yq && \
    chown apps:apps /app/yq && \
    cp -f /app/yq /usr/bin/yq

USER apps
