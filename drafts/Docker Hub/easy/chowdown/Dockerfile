# Builder: upstream gh-pages is Jekyll source, not a built static site, so it is built here.
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454 AS builder

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
FROM ghcr.io/trueforge-org/nginx:1.28.3@sha256:1e4f20bfcf614853820179bb28127b1375061c09f565bb7010495845d4742c9f

USER root

COPY --from=builder --chown=568:568 /tmp/site/ /usr/share/nginx/html/
COPY --from=builder --chown=568:568 /tmp/src/LICENSE /usr/share/licenses/chowdown/LICENSE

USER apps
COPY --chmod=0755 . /

EXPOSE 8080

VOLUME /config
