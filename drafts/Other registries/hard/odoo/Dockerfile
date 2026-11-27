
FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d

# set version label
ARG VERSION
ARG TARGETARCH
# Pinned Odoo nightly deb (no Renovate datasource; bump by hand together with ODOO_SHA)
ARG ODOO_RELEASE=20261112
ARG ODOO_SHA=9b69ffe4ebf8a4412b312d1f71494112d8410e12
USER root

ENV TMPDIR=/tmp

# UNVERIFIED: upstream is ubuntu:noble, this base is 26.04. Package availability and the odoo .deb
# dependency resolution must be checked on the first build. Check overlap with apps/python first.
RUN \
  echo "**** install runtime packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    ca-certificates \
    fonts-noto-cjk \
    node-less \
    nodejs \
    npm \
    postgresql-client \
    python3-magic \
    python3-num2words \
    python3-odf \
    python3-pdfminer \
    python3-phonenumbers \
    python3-pyldap \
    python3-qrcode \
    python3-renderpm \
    python3-setuptools \
    python3-slugify \
    python3-vobject \
    python3-watchdog \
    python3-xlrd \
    python3-xlwt \
    xz-utils

# wkhtmltopdf: arch map and sha1 values as used by upstream odoo/docker (ppc64le not supported here)
RUN \
  echo "**** install wkhtmltopdf ****" && \
  case "${TARGETARCH}" in \
    amd64) WK_ARCH=amd64; WK_SHA=967390a759707337b46d1c02452e2bb6b2dc6d59 ;; \
    arm64) WK_ARCH=arm64; WK_SHA=90f6e69896d51ef77339d3f3a20f8582bdf496cc ;; \
    *) echo "unsupported arch: ${TARGETARCH}" >&2; exit 1 ;; \
  esac && \
  curl -fL -o /tmp/wkhtmltox.deb \
    "https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-3/wkhtmltox_0.12.6.1-3.jammy_${WK_ARCH}.deb" && \
  echo "${WK_SHA}  /tmp/wkhtmltox.deb" | sha1sum -c - && \
  apt-get install -y --no-install-recommends /tmp/wkhtmltox.deb && \
  rm -f /tmp/wkhtmltox.deb

# Odoo nightly deb, checked with the sha1 from upstream. Plain http is what upstream uses; the sha1 check covers it.
RUN \
  echo "**** install odoo ${ODOO_RELEASE} ****" && \
  curl -fL -o /tmp/odoo.deb \
    "http://nightly.odoo.com/20.0/nightly/deb/odoo_20.0.${ODOO_RELEASE}_all.deb" && \
  echo "${ODOO_SHA}  /tmp/odoo.deb" | sha1sum -c - && \
  apt-get install -y --no-install-recommends /tmp/odoo.deb && \
  rm -f /tmp/odoo.deb

# UNVERIFIED: rtlcss from npm, as upstream does. npm is purged afterwards; rtlcss stays in the global node_modules.
# UNVERIFIED: licence path inside the deb (/usr/share/doc/odoo/copyright) was not checked.
RUN \
  echo "**** install rtlcss ****" && \
  npm install -g rtlcss && \
  apt-get purge -y --auto-remove npm && \
  echo "**** licence and cleanup ****" && \
  install -Dm0644 /usr/share/doc/odoo/copyright /usr/share/licenses/odoo/copyright && \
  apt-get autoremove -y && \
  apt-get clean && \
  rm -rf \
    /tmp/* \
    $HOME/.cache \
    /var/lib/apt/lists/*

# add local files (defaults/odoo.conf is seeded to /defaults by this copy)
USER apps
COPY --chmod=0755 . /

# 8071 is listed in upstream EXPOSE only; not confirmed as a listener
EXPOSE 8069 8071 8072
VOLUME /config
