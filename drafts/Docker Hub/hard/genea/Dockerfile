FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a AS builder

ARG VERSION
WORKDIR /tmp
ENV HOME=/tmp
USER root

# The project has no tags or releases, so VERSION is a commit SHA of main (see docker-bake.hcl)
ADD https://github.com/genea-app/genea-app.git#${VERSION} /tmp/src

# Publish only what index.html references: no tests, package files or sample trees
RUN mkdir -p /tmp/dist \
    && cd /tmp/src \
    && cp -a index.html js css components resources modals img favicon.ico /tmp/dist/

FROM ghcr.io/trueforge-org/nginx:1.28.3@sha256:3a862278083a33d9ff969e987ee3a6ab24d2b928c35df07b2e69fa6f5d4e6cc1

USER root
COPY --from=builder --chown=568:568 /tmp/dist/ /usr/share/nginx/html
COPY --from=builder /tmp/src/LICENSE /usr/share/licenses/genea/LICENSE

# Copy configuration files into container
COPY --chmod=0755 . /

EXPOSE 8080
VOLUME /config

USER apps
COPY --chmod=0755 . /
WORKDIR /usr/share/nginx/html
