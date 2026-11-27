FROM ghcr.io/trueforge-org/java17:17.0.16@sha256:74b81362a2cf4b7f6efb8eb67baf0d1090ce56b38fc9e7a0dc11333b35179e1a

# UNVERIFIED: version from vendor download page (0.305.17); the Starter downloads the game itself at first start
ARG VERSION

USER root

# UNVERIFIED: the Starter jar is fetched over plain http (as upstream does), no checksum published.
# UNVERIFIED: https://files.star-made.org/ reachability. unzip is not installed because the Starter's need for it is unverified.
RUN mkdir -p /app/starmade \
 && curl -fsSL -o /app/starmade/StarMade-Starter.jar \
      "http://files.star-made.org/StarMade-Starter.jar" \
 && chown -R root:root /app/starmade \
 && chmod -R 755 /app/starmade

# run as 568
USER apps
COPY --chmod=0755 . /

# UNVERIFIED: EXPOSE 4242 is omitted until the server port is confirmed by running the server
WORKDIR /config
VOLUME ["/config"]
