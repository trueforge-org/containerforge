FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d

ARG VERSION
# TODO: sha256 of the v0.6.4 source archive. Not an upstream checksum; compute it from the
# downloaded archive during the build step and pin it here. The build fails until it is set.
ARG HEADPHONES_SHA256=""

ENV PYTHONDONTWRITEBYTECODE=1

USER root

# runtime packages (apt versions are not tied to VERSION; UNVERIFIED that the 26.04 archive has shntool)
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ffmpeg \
      flac \
      shntool \
 && rm -rf /var/lib/apt/lists/*

# download the source archive (v0.6.4 has no release binary; dependencies are vendored under lib/)
RUN mkdir -p /app/headphones \
 && curl -fsSL -o /tmp/headphones.tar.gz \
      "https://github.com/rembo10/headphones/archive/refs/tags/${VERSION}.tar.gz" \
 && echo "${HEADPHONES_SHA256}  /tmp/headphones.tar.gz" | sha256sum -c - \
 && tar xzf /tmp/headphones.tar.gz -C /app/headphones --strip-components=1 \
 \
 # license from the archive
 && mkdir -p /usr/share/licenses/headphones \
 && cp /app/headphones/LICENSE /usr/share/licenses/headphones/LICENSE \
 \
 # permissions and cleanup
 && chown -R root:root /app/headphones \
 && chmod -R 755 /app/headphones \
 && rm -rf /tmp/*

# run as 568
USER apps
COPY --chmod=0755 . /

WORKDIR /config
EXPOSE 8181
VOLUME ["/config"]
