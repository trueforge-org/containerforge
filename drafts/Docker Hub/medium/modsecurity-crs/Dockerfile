
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

# OWASP CRS release version (tag v<VERSION>)
ARG VERSION

USER root

# Apache and ModSecurity come from the Ubuntu archive.
# UNVERIFIED: apt package versions and arm64 availability of libapache2-mod-security2 (pin once checked)
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      apache2 \
      libapache2-mod-security2 \
      gnupg \
 && rm -rf /var/lib/apt/lists/*

# CRS, verified against the OWASP signing key from coreruleset.org
# UNVERIFIED: the release asset coreruleset-<VERSION>.tar.gz exists (pattern from upstream apache/Dockerfile)
RUN mkdir -p /app/owasp-crs /app/modsecurity /tmp/gnupg \
 && chmod 700 /tmp/gnupg \
 && curl -fsSL -o /tmp/crs.tar.gz \
      "https://github.com/coreruleset/coreruleset/releases/download/v${VERSION}/coreruleset-${VERSION}.tar.gz" \
 && curl -fsSL -o /tmp/crs.tar.gz.asc \
      "https://github.com/coreruleset/coreruleset/releases/download/v${VERSION}/coreruleset-${VERSION}.tar.gz.asc" \
 && curl -fsSL -o /tmp/security.asc "https://coreruleset.org/security.asc" \
 && GNUPGHOME=/tmp/gnupg gpg --batch --import /tmp/security.asc \
 && GNUPGHOME=/tmp/gnupg gpg --batch --verify /tmp/crs.tar.gz.asc /tmp/crs.tar.gz \
 && tar -xzf /tmp/crs.tar.gz -C /app/owasp-crs --strip-components=1 \
 && install -D -m 0644 /app/owasp-crs/LICENSE /usr/share/licenses/modsecurity-crs/LICENSE \
 \
 # ModSecurity base config from the packaged recommended file; unicode map kept under /app
 # UNVERIFIED: the packaged paths under /etc/modsecurity on Ubuntu 26.04
 && install -m 0644 /etc/modsecurity/modsecurity.conf-recommended /app/modsecurity/modsecurity.conf \
 && install -m 0644 /etc/modsecurity/unicode.mapping /app/modsecurity/unicode.mapping \
 && sed -i 's|^SecUnicodeMapFile .*|SecUnicodeMapFile /app/modsecurity/unicode.mapping 20127|' /app/modsecurity/modsecurity.conf \
 \
 && chown -R root:root /app \
 && chmod -R 755 /app \
 && rm -rf /tmp/crs.tar.gz /tmp/crs.tar.gz.asc /tmp/security.asc /tmp/gnupg

# run as 568
USER apps
COPY --chmod=0755 . /

ENV HOME=/config \
    TZ=Etc/UTC

EXPOSE 8080
VOLUME ["/config"]
CMD ["/start.sh"]
