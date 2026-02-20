FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:36c48bc0fd413c8ef2ae9761b1decc96fa8295f44407a9b7280bd137c2109355

ARG VERSION

USER root

RUN apt-get update && \
    apt-get install -y --no-install-recommends "memcached=${VERSION}" && \
    apt-get purge -y --auto-remove && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

USER apps
COPY --chmod=0755 container-test.yaml /container-test.yaml

EXPOSE 11211

CMD ["memcached"]
