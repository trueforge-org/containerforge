
# stay on python 3.14 until onnxruntime publishes cp315 wheels
FROM ghcr.io/trueforge-org/python:3.14.8@sha256:f099b700b824b7760cb846418f84a2c14c2f04992320506ab3ca5b79d3ac1232

# set version label
ARG VERSION
ARG TARGETARCH
USER root

RUN pip3 install -U --no-cache-dir \
    pip \
    wheel && \
  pip3 install -U --no-cache-dir --find-links https://wheel-index.linuxserver.io/ubuntu/ \
    piper-tts \
    "wyoming-piper==${VERSION}" && \
  echo "**** cleanup ****" && \
  chown -R apps:apps /app && chmod -R 755 /app && \
  rm -rf \
    /var/lib/apt/lists/* \
    /tmp/*

USER apps
COPY --chmod=0755 . /
COPY ./ /

VOLUME /config

EXPOSE 10200
