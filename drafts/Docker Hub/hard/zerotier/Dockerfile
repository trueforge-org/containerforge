# UNVERIFIED: base digest. The plan listed f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a...; the other 26.04 apps in apps/ use f01a4295.... Reconcile before merge.
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION

USER root

# UNVERIFIED: the apt key fingerprint (compare with docs.zerotier.com) and the `resolute` suite for 26.04.
# hadolint ignore=DL3008,DL3015
RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates curl gnupg && \
    curl -fsSL -o /tmp/zerotier.gpg.asc "https://download.zerotier.com/contact%40zerotier.com.gpg" && \
    gpg --dearmor -o /usr/share/keyrings/zerotier.gpg /tmp/zerotier.gpg.asc && \
    echo "deb [signed-by=/usr/share/keyrings/zerotier.gpg] http://download.zerotier.com/debian/resolute resolute main" \
        > /etc/apt/sources.list.d/zerotier.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends "zerotier-one=${VERSION}" iproute2 libcap2-bin && \
    installed="$(dpkg-query -W -f='${Version}' zerotier-one)" && \
    test "${installed%%-*}" = "${VERSION}" && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Upstream runs as root with state in /var/lib/zerotier-one. Here the state lives in /config (symlink),
# and the daemon gets file capabilities instead of root.
# UNVERIFIED: file capabilities are ignored under no-new-privileges, and the symlink as home is not tested.
RUN rm -rf /var/lib/zerotier-one && \
    ln -s /config /var/lib/zerotier-one && \
    setcap cap_net_admin,cap_net_raw+eip /usr/sbin/zerotier-one && \
    install -d -o 568 -g 568 /config

# Licenses: MPL-2.0 for the core and a source-available license for nonfree/ (see docker-bake.hcl).
RUN install -d /usr/share/licenses/zerotier && \
    for f in LICENSE.txt LICENSE-MPL.txt; do \
        curl -fsSL -o "/usr/share/licenses/zerotier/${f}" "https://raw.githubusercontent.com/zerotier/ZeroTierOne/${VERSION}/${f}"; \
    done && \
    curl -fsSL -o /usr/share/licenses/zerotier/nonfree-LICENSE.md \
        "https://raw.githubusercontent.com/zerotier/ZeroTierOne/${VERSION}/nonfree/LICENSE.md" && \
    test -s /usr/share/licenses/zerotier/LICENSE.txt

ENV HOME=/config

USER apps
COPY --chmod=0755 . /

EXPOSE 9993/udp

VOLUME /config

CMD ["/start.sh"]
