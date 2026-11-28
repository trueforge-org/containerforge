
# Draft from plan.md section 4. Not built.
# BLOCKER (plan section 3, option A): Red-DiscordBot 3.5.24 requires Python <3.12 (PyPI requires_python), and the
# python base is 3.15.2, so this draft uses the ubuntu base. The RUN step below expects CPython 3.11 at
# /usr/local/bin/python3.11. That interpreter is not yet provided: its source and checksum are UNVERIFIED and must
# be pinned in a separate step before this builds.
# UNVERIFIED: ship the GPL-3.0 LICENSE file (not fetched in context).

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

# set version label
ARG VERSION
ARG TARGETARCH
USER root

ENV PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_ROOT_USER_ACTION=ignore \
    SODIUM_INSTALL=system \
    HOME=/config

# build packages for native wheels (apsw, PyNaCl, cffi); removed again after the install
RUN \
  echo "**** install build packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    build-essential \
    libffi-dev \
    libsodium-dev && \
  echo "**** install red into a prebuilt venv ****" && \
  python3.11 -m venv /app/venv && \
  /app/venv/bin/pip install "Red-DiscordBot==${VERSION}" && \
  echo "**** cleanup ****" && \
  apt-get purge -y --auto-remove build-essential && \
  apt-get clean && \
  rm -rf /tmp/* /var/lib/apt/lists/* && \
  chown -R root:root /app && \
  chmod -R 755 /app

# add local files (start.sh)
USER apps
COPY --chmod=0755 . /

# data (config, cogs, venv) lives in /config
VOLUME /config
WORKDIR /config
