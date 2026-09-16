FROM ghcr.io/trueforge-org/ubuntu:26.4@sha256:82ba374994be0491824b19f17ba1f47ffa97ba2feac1d6614285bb9d82e5b69b

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
