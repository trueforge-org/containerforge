FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:bec52e97e32c21da9b7f6f425804460202895214a0d1c18c103aa120d497c9d2

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
