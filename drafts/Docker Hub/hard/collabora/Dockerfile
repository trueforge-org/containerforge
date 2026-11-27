FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

ARG VERSION
USER root

# VERSION is the collabora/code Docker tag (26.04.6.2.1). The apt version maps to 26.04.6.2-1.
# UNVERIFIED: coolwsd 26.04.6.2-1 (from plan.md; the Packages stanza was not read), SHA256 not checked.
# code-brand 26.04.6-2 is confirmed; apt resolves collaboraoffice* through the coolwsd dependency.
RUN set -eux; \
    install -d -m 0755 /etc/apt/keyrings; \
    curl -fsSL https://collaboraoffice.com/downloads/gpg/collaboraonline-release-keyring.gpg \
        -o /etc/apt/keyrings/collaboraonline-release-keyring.gpg; \
    printf '%s\n' \
        'Types: deb' \
        'URIs: https://www.collaboraoffice.com/repos/CollaboraOnline/CODE-deb' \
        'Suites: ./' \
        'Signed-By: /etc/apt/keyrings/collaboraonline-release-keyring.gpg' \
        > /etc/apt/sources.list.d/collaboraonline.sources; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        "coolwsd=${VERSION%.*}-${VERSION##*.}" \
        code-brand \
        cpio \
        fonts-dejavu \
        fonts-liberation \
        libcap2-bin \
        openssl; \
    # UNVERIFIED: coolwsd-systemplate-setup path and arguments. Confirm with `dpkg -L coolwsd`.
    # The systemplate is built at image build time so the runtime rootfs can stay read-only.
    coolwsd-systemplate-setup /opt/cool/systemplate /opt/collaboraoffice; \
    # Non-root without added capabilities: file-capability binaries fail to exec when the bounding set
    # lacks those caps, so drop their file caps. UNVERIFIED filenames.
    for f in /usr/bin/coolforkit-caps /usr/bin/coolmount; do \
        if [ -e "$f" ]; then setcap -r "$f"; fi; \
    done; \
    mkdir -p /usr/share/licenses/collabora; \
    cp /usr/share/doc/coolwsd/copyright /usr/share/licenses/collabora/COPYRIGHT; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/* /tmp/*

ENV HOME=/config \
    LC_CTYPE=C.UTF-8

USER apps
COPY --chmod=0755 . /

EXPOSE 9980
VOLUME /config

CMD ["/start.sh"]
