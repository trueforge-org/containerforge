FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH
USER root

ENV \
  HOME=/config \
  DATA_DIRECTORY=/config/data \
  PASSWORD_FILE=/config/.htpasswd

# htpasswd is needed by the create_user and delete_user helpers.
# apache2-utils is not in the ubuntu base, so install it here.
RUN apt-get update && \
  apt-get install -y --no-install-recommends apache2-utils && \
  rm -rf /var/lib/apt/lists/*

RUN set -eux; \
  base="https://github.com/restic/rest-server/releases/download/v${VERSION#v}"; \
  f="rest-server_${VERSION#v}_linux_${TARGETARCH}.tar.gz"; \
  curl -fsSL -o "/tmp/${f}" "${base}/${f}"; \
  curl -fsSL -o /tmp/SHA256SUMS "${base}/SHA256SUMS"; \
  (cd /tmp && grep " ${f}\$" SHA256SUMS | sha256sum -c -); \
  mkdir -p /tmp/rs /usr/share/licenses/restic-rest-server; \
  tar xzf "/tmp/${f}" -C /tmp/rs --strip-components=1; \
  install -m 0755 /tmp/rs/rest-server /app/rest-server; \
  install -m 0644 /tmp/rs/LICENSE /usr/share/licenses/restic-rest-server/LICENSE; \
  chown -R apps:apps /app; chmod -R 755 /app; \
  rm -rf /tmp/rs /tmp/SHA256SUMS "/tmp/${f}"

USER apps
COPY --chmod=0755 . /

EXPOSE 8000
VOLUME /config
