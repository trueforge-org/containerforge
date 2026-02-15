# hadolint ignore=DL3007
FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:ede54cb88fd5efef6f41610146f10b4399f5e584d9227202b6c14a515a35e94e

ARG PACKAGE_VERSION

USER root

# hadolint ignore=DL3008,DL3015
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        "valkey-server=${PACKAGE_VERSION}" \
    && apt-get purge -y --auto-remove \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY --chmod=0755 health /health

ENV REDIS_PORT=6379

USER apps:apps

HEALTHCHECK CMD ["/bin/sh", "-c", "/health/ping_liveness_local.sh 2"]

EXPOSE 6379

CMD ["valkey-server", "--bind", "0.0.0.0", "--port", "6379"]
