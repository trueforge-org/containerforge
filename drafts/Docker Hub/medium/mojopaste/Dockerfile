# Initial draft from drafts/Docker Hub/medium/mojopaste/plan.md. Not built yet.
# BLOCKED: the upstream license is unverified. Do not merge until the LICENSE value and the license file are set.

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

ARG VERSION
ARG TARGETARCH
USER root

ENV MOJO_MODE=production \
    PASTE_DIR=/config/data \
    PASTE_ENABLE_CHARTS=1 \
    PERL_CPANM_HOME=/tmp/.cpanm \
    HOME=/config

RUN echo "**** install perl and build tools ****" && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        cpanminus \
        libssl-dev \
        perl && \
    rm -rf /var/lib/apt/lists/*
# UNVERIFIED: apt package names on Ubuntu 26.04. curl is assumed present in the ubuntu base (as in apps/thelounge).

RUN echo "**** download mojopaste ****" && \
    mkdir -p /app/mojopaste && \
    curl -fsSL -o /tmp/mojopaste.tar.gz \
        "https://github.com/jhthorsen/app-mojopaste/archive/refs/tags/${VERSION}.tar.gz" && \
    tar xzf /tmp/mojopaste.tar.gz -C /app/mojopaste --strip-components=1 && \
    rm -f /tmp/mojopaste.tar.gz
# UNVERIFIED: the tag archive layout and that tag 1.05 contains script/mojopaste and a cpanfile.

RUN echo "**** install perl dependencies ****" && \
    cpanm -M https://cpan.metacpan.org --notest --installdeps /app/mojopaste
# UNVERIFIED: Text::CSV is expected from the cpanfile. Add an explicit install only if --installdeps misses it.

RUN echo "**** prepare data directory and permissions ****" && \
    mkdir -p /config && \
    chown apps:apps /config && \
    chown -R apps:apps /app/mojopaste && \
    chmod -R 755 /app/mojopaste && \
    rm -rf /tmp/* /var/lib/apt/lists/*
# BLOCKED: once the license is confirmed, copy LICENSE to /usr/share/licenses/mojopaste/LICENSE here.

USER apps
COPY --chmod=0755 . /

EXPOSE 8080
VOLUME /config
