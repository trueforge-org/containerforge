# Initial draft from drafts/Docker Hub/medium/photo-stream/plan.md. Not built yet.
# Build-once static site: Jekyll runs in the build stage and nginx serves the output.

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454 AS build
ARG VERSION
USER root
ENV GEM_HOME=/tmp/gems \
    GEM_PATH=/tmp/gems \
    BUNDLE_PATH=/tmp/bundle \
    BUNDLE_APP_CONFIG=/tmp/bundle-config

RUN echo "**** install ruby and build tools ****" && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        git \
        libvips-dev \
        ruby-full && \
    rm -rf /var/lib/apt/lists/*
# UNVERIFIED: Ruby version against the upstream Gemfile (upstream tag built on ruby 3.1.3).

RUN echo "**** download photo-stream ****" && \
    mkdir -p /tmp/src && \
    curl -fL "https://github.com/waschinski/photo-stream/archive/refs/tags/${VERSION}.tar.gz" \
        | tar xz -C /tmp/src --strip-components=1
# UNVERIFIED: the tag archive is not checksum-pinned (no release assets). Record a sha256 after the first build.

RUN echo "**** build site ****" && \
    cd /tmp/src && \
    bundle install && \
    bundle exec jekyll build --destination /tmp/site && \
    rm -rf /tmp/gems /tmp/bundle /tmp/bundle-config

FROM ghcr.io/trueforge-org/nginx:1.28.3@sha256:3a862278083a33d9ff969e987ee3a6ab24d2b928c35df07b2e69fa6f5d4e6cc1
ARG VERSION
USER root

COPY --from=build /tmp/site/ /app/site/
COPY --from=build /tmp/src/LICENSE /usr/share/licenses/photo-stream/LICENSE
RUN chown -R apps:apps /app && \
    chmod -R 755 /app

USER apps
COPY --chmod=0755 . /

EXPOSE 8080
VOLUME /config
CMD ["/start.sh"]
