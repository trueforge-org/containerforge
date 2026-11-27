FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454 AS builder

ARG VERSION
USER root
WORKDIR /tmp/src

# Static site from a pinned commit (upstream has no releases or tags).
# UNVERIFIED: VERSION is the commit SHA at head of master (checked 2026-11-23).
RUN set -eux; \
    curl -fsSL -o /tmp/src.tar.gz "https://github.com/DavidSpek/homelablabelmaker/archive/${VERSION}.tar.gz"; \
    tar xzf /tmp/src.tar.gz -C /tmp/src --strip-components=1; \
    rm /tmp/src.tar.gz; \
    test -f index.html; \
    mkdir -p /tmp/site; \
    cp -r index.html css fonts img js v1 reddit_snoo.png /tmp/site/

FROM ghcr.io/trueforge-org/nginx:1.28.3@sha256:3a862278083a33d9ff969e987ee3a6ab24d2b928c35df07b2e69fa6f5d4e6cc1

ARG VERSION
USER root

# Upstream ships no license file. Record provenance instead of inventing a license.
RUN set -eux; \
    mkdir -p /usr/share/licenses/homelablabelmaker; \
    printf '%s\n' \
      "Source: https://github.com/DavidSpek/homelablabelmaker" \
      "Commit: ${VERSION}" \
      "No license file is provided by the upstream repository." \
      > /usr/share/licenses/homelablabelmaker/NOTICE

COPY --from=builder --chown=568:568 /tmp/site/ /usr/share/nginx/html/

# Copy configuration files into container
COPY --chmod=755 ./ /

USER apps
COPY --chmod=0755 . /

WORKDIR /usr/share/nginx/html

VOLUME /config
