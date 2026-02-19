# hadolint ignore=DL3007
ARG VERSION

FROM docker.io/renovate/renovate:${VERSION}-full


ARG TARGETARCH
ARG TARGETARCH=${TARGETARCH/arm64/ARM64}
ARG TARGETARCH=${TARGETARCH/amd64/amd64}
# renovate: datasource=github-releases depName=trueforge-org/forgetool
ARG FORGETOOL_VERSION=3.0.2

# Download and set up the forgetool binary
RUN curl -L "https://github.com/trueforge-org/forgetool/releases/download/v${FORGETOOL_VERSION}/forgetool_${FORGETOOL_VERSION}_linux_${TARGETARCH}.tar.gz" -o /tmp/forgetool.tar.gz \
    && tar -xzvf /tmp/forgetool.tar.gz -C /usr/local/bin \
    && chmod +x /usr/local/bin/forgetool \
    && rm /tmp/forgetool.tar.gz

COPY container-test.yaml /container-test.yaml
