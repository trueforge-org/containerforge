
FROM ghcr.io/trueforge-org/java17:17.0.16@sha256:74b81362a2cf4b7f6efb8eb67baf0d1090ce56b38fc9e7a0dc11333b35179e1a

ARG VERSION

ENV JELU_DATABASE_PATH=/config/database/ \
    JELU_FILES_IMAGES=/config/files/images/ \
    JELU_FILES_IMPORTS=/config/files/imports/ \
    HOME=/config

USER root

# download jelu jar and license, verify the jar checksum
# UNVERIFIED: the LICENSE tag path may not exist for every release; fall back to main if missing
# refresh the sha256 on every VERSION bump
RUN mkdir -p /app /usr/share/licenses/jelu \
 && curl -fsSL -o /app/jelu.jar \
      "https://github.com/bayang/jelu/releases/download/v${VERSION}/jelu-${VERSION}.jar" \
 && echo "824446732a02f2c6296c3278c3664e6973f2612b9fd5228a3f7c63ffb533276e  /app/jelu.jar" | sha256sum -c - \
 && curl -fsSL -o /usr/share/licenses/jelu/LICENSE \
      "https://raw.githubusercontent.com/bayang/jelu/v${VERSION}/LICENSE" \
 && chown -R root:root /app /usr/share/licenses/jelu \
 && chmod -R 755 /app /usr/share/licenses/jelu \
 && rm -rf /tmp/*

# run as 568
USER apps
COPY --chmod=0755 . /

EXPOSE 11111
VOLUME /config
