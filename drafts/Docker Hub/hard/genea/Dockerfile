FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454 AS builder

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

FROM ghcr.io/trueforge-org/nginx:1.28.3@sha256:1e4f20bfcf614853820179bb28127b1375061c09f565bb7010495845d4742c9f

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
