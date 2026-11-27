FROM ghcr.io/trueforge-org/java25:25.0.1@sha256:22a0f8a73c79e2f733c7513aefceef24ab8a213fd35af0ab1946996efc21636d

ARG VERSION=v3.5.0
# sha256 of Stirling-PDF.jar for ${VERSION} (GitHub release asset digest).
# Bump together with VERSION; renovate does not update this line.
ARG JAR_SHA256=53e2cd9fd3b8b8beaaab7e6c2c929c80f6f355326418e6703790ed412e2afca9

ENV HOME=/config \
    TMPDIR=/tmp \
    TEMP=/tmp \
    TMP=/tmp \
    STIRLING_TEMPFILES_DIRECTORY=/tmp/stirling-pdf \
    DBUS_SESSION_BUS_ADDRESS=/dev/null \
    ORT_DISABLE_TELEMETRY=1

USER root

# UNVERIFIED: package list inferred from the upstream embedded image and the
# draft. Check each name installs on the java25 base and is needed by 3.5.0.
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      tesseract-ocr \
      ocrmypdf \
      ghostscript \
      qpdf \
      unpaper \
      pngquant \
      poppler-utils \
 && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /app /usr/share/licenses/stirling-pdf /tmp/stirling-pdf \
 && curl -fsSL -o /app/Stirling-PDF.jar \
      "https://github.com/Stirling-Tools/Stirling-PDF/releases/download/${VERSION}/Stirling-PDF.jar" \
 && echo "${JAR_SHA256}  /app/Stirling-PDF.jar" | sha256sum -c - \
 # UNVERIFIED: LICENSE is MIT with carve-outs; ship the proprietary/saas/engine license files too if the JAR contains them.
 && curl -fsSL -o /usr/share/licenses/stirling-pdf/LICENSE \
      "https://raw.githubusercontent.com/Stirling-Tools/Stirling-PDF/${VERSION}/LICENSE" \
 && chmod -R 755 /app /usr/share/licenses/stirling-pdf

WORKDIR /config
VOLUME ["/config"]
EXPOSE 8080

COPY --chmod=0755 . /

USER apps
