FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION

# Upstream tag 1.1 (skeeto/endlessh). The apt package below is the matching Ubuntu build.
# Bump the package pin by hand together with the VERSION in docker-bake.hcl.
USER root

RUN set -eux; \
    apt-get update; \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends endlessh=1.1-5.1build1; \
    test "$(dpkg-query -W -f='${Version}' endlessh)" = "1.1-5.1build1"; \
    rm -rf /var/lib/apt/lists/*

# UNVERIFIED: copyright file path from the Ubuntu package (check with dpkg -L endlessh)
RUN set -eux; \
    mkdir -p /usr/share/licenses/endlessh; \
    cp /usr/share/doc/endlessh/copyright /usr/share/licenses/endlessh/

USER apps
COPY --chmod=0755 . /

EXPOSE 2222

CMD [""]
