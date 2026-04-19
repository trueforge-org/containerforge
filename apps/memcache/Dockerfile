FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:8b0b1f042b2fd6d7a2a8ad73e0b4470404cabfee1d209ae04fe6fcd2cc761152

ARG VERSION

USER root

RUN apt-get update && \
    apt-get install -y --no-install-recommends "memcached=${VERSION}" && \
    apt-get purge -y --auto-remove && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

USER apps
COPY --chmod=0755 . /

EXPOSE 11211

CMD ["memcached"]
