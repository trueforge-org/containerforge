FROM ghcr.io/trueforge-org/java21:21.0.8@sha256:5651f46cebe5a42ff069da176dd7ab50f6b050169493fe06ebc1be2fe81cd15e

ARG VERSION
USER root
WORKDIR /app

ENV TIKA_VERSION=${VERSION}

# The Tika server jar is architecture-independent. Verify it against the .sha512 that Apache publishes.
# UNVERIFIED: the .sha512 file layout was not read. The cut below assumes "<hash>  <file>" (GNU format).
RUN set -eux; \
  mkdir -p /app/bin /tika-extras; \
  curl -fsSL -o /app/bin/tika-server.jar \
    "https://archive.apache.org/dist/tika/${VERSION}/tika-server-standard-${VERSION}.jar"; \
  curl -fsSL -o /tmp/tika-server.jar.sha512 \
    "https://archive.apache.org/dist/tika/${VERSION}/tika-server-standard-${VERSION}.jar.sha512"; \
  echo "$(cut -d' ' -f1 /tmp/tika-server.jar.sha512)  /app/bin/tika-server.jar" | sha512sum -c -; \
  rm -f /tmp/tika-server.jar.sha512

# UNVERIFIED: the license path in the repo at this tag. Confirm during the build.
RUN set -eux; \
  mkdir -p /usr/share/licenses/tika; \
  curl -fsSL -o /usr/share/licenses/tika/LICENSE.txt \
    "https://raw.githubusercontent.com/apache/tika/${VERSION}/LICENSE.txt"; \
  chmod -R 755 /app /tika-extras; \
  rm -rf /tmp/*

USER apps
COPY --chmod=0755 . /

EXPOSE 9998
WORKDIR /app
