# Fetch the static Speed-Test files from the upstream commit.
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a AS fetch

ARG VERSION
USER root
WORKDIR /tmp/src

# VERSION is an upstream commit SHA (no releases or tags exist). The tarball pins the content.
RUN set -eux; \
    curl -fsSL "https://github.com/openspeedtest/Speed-Test/archive/${VERSION}.tar.gz" \
        | tar xz --strip-components=1

FROM ghcr.io/trueforge-org/nginx:1.28.3@sha256:3a862278083a33d9ff969e987ee3a6ab24d2b928c35df07b2e69fa6f5d4e6cc1

USER root

# Replace the base web root with the speed-test static files. Upstream's TLS key pair is not shipped.
RUN rm -rf /usr/share/nginx/html/*

COPY --from=fetch --chown=568:568 /tmp/src/index.html /tmp/src/hosted.html /tmp/src/downloading /tmp/src/upload /usr/share/nginx/html/
COPY --from=fetch --chown=568:568 /tmp/src/assets /usr/share/nginx/html/assets
COPY --from=fetch /tmp/src/License.md /usr/share/licenses/openspeedtest/LICENSE

USER apps
COPY --chmod=0755 . /
WORKDIR /usr/share/nginx/html

EXPOSE 8080
