# Build stage: the v5 editor is built from the tagged source with the base's Node and npm.
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454 AS builder

ARG VERSION

USER root
ENV HOME=/tmp
WORKDIR /tmp/src

# UNVERIFIED: Webpack 2 may need NODE_OPTIONS=--openssl-legacy-provider, or an older Node in this stage, on the base's Node.
# UNVERIFIED: the upstream v4 editor bundle (npm pack stackedit@4.3.22) may be needed. Check whether the v5 dist references it.
RUN curl -fsSL "https://github.com/benweet/stackedit/archive/refs/tags/v${VERSION}.tar.gz" | tar xz -C /tmp/src --strip-components=1 && \
    npm install --unsafe-perm && \
    NODE_ENV=production npm run build

FROM ghcr.io/trueforge-org/nginx:1.28.3@sha256:3a862278083a33d9ff969e987ee3a6ab24d2b928c35df07b2e69fa6f5d4e6cc1

USER root
# UNVERIFIED: dist/ is the webpack default output directory. Confirm it in the build.
COPY --from=builder --chown=568:568 /tmp/src/dist/ /usr/share/nginx/html
COPY --from=builder /tmp/src/LICENSE /usr/share/licenses/stackedit/LICENSE

USER apps
COPY --chmod=0755 . /

EXPOSE 8080
VOLUME /config
WORKDIR /usr/share/nginx/html
CMD ["/start.sh"]
