## TODO: also make go-yq container
FROM ghcr.io/trueforge-org/python:3.13.12@sha256:cc5a5a300743bf95669130b982874279d999d8ac2691788c9c83f9493adb5bdf

# set version label
ARG VERSION
ARG TARGETARCH
USER root
COPY --chmod=0755 . /

RUN echo "**** install app ****" && \
  python3 -m venv /app/venv && \
  pip install -U --no-cache-dir \
    pip \
    wheel && \
  pip install -U --no-cache-dir --find-links https://wheel-index.linuxserver.io/ubuntu/ \
    yq=="${VERSION}" && \
  chown -R apps:apps /app && chmod -R 755 /app
