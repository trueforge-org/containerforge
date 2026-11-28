# Builder: upstream gh-pages is Jekyll source, not a built static site, so it is built here.
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a AS builder

ARG VERSION
USER root
ENV HOME=/tmp
WORKDIR /tmp/src

# UNVERIFIED: the Ubuntu universe jekyll 4.4.1 package builds the upstream site.
RUN echo "*** Installing Jekyll ***" && \
  apt-get update && \
  apt-get install -y --no-install-recommends jekyll && \
  rm -rf /var/lib/apt/lists/*

# No upstream checksum exists; the full commit SHA in the URL is the integrity control.
RUN echo "*** Building chowdown ${VERSION} ***" && \
  curl -fsSL -o /tmp/chowdown.tar.gz "https://github.com/clarklab/chowdown/archive/${VERSION}.tar.gz" && \
  tar xzf /tmp/chowdown.tar.gz -C /tmp/src --strip-components=1 && \
  rm -f /tmp/chowdown.tar.gz && \
  jekyll build --source /tmp/src --destination /tmp/site --baseurl "" --disable-disk-cache && \
  test -f /tmp/site/index.html && \
  (grep -rl 'https://chowdown.io' /tmp/site || true)

# Runtime: the ContainerForge nginx base serves /usr/share/nginx/html and seeds /config.
FROM ghcr.io/trueforge-org/nginx:1.28.3@sha256:3a862278083a33d9ff969e987ee3a6ab24d2b928c35df07b2e69fa6f5d4e6cc1

USER root

COPY --from=builder --chown=568:568 /tmp/site/ /usr/share/nginx/html/
COPY --from=builder --chown=568:568 /tmp/src/LICENSE /usr/share/licenses/chowdown/LICENSE

USER apps
COPY --chmod=0755 . /

EXPOSE 8080

VOLUME /config
