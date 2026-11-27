FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d

ARG VERSION
# Commit of the 3.8.9 tag. Upstream publishes no checksum for the source archive, so the clone is checked against this commit.
ARG CTFD_COMMIT=5f345fbaa424e6a22b51addf7f27430927879ae2
USER root

# UNVERIFIED: the base is expected to be Debian/Ubuntu with apt, and to ship /app/venv (plan.md section 3). Check both on the first build.
RUN echo "*** Fetching CTFd ***" && \
  apt-get update && \
  apt-get install -y --no-install-recommends git && \
  git -c advice.detachedHead=false clone --depth 1 --branch "${VERSION}" \
    https://github.com/CTFd/CTFd.git /tmp/CTFd && \
  test "$(git -C /tmp/CTFd rev-parse HEAD)" = "${CTFD_COMMIT}" && \
  rm -rf /tmp/CTFd/.git && \
  mkdir -p /app && \
  mv /tmp/CTFd /app/CTFd && \
  apt-get purge -y --auto-remove git && \
  rm -rf /var/lib/apt/lists/*

# Dependencies are installed into /app/venv at build time, which is allowed. Nothing is written there at runtime.
# UNVERIFIED: build-essential, libffi-dev and libssl-dev are needed only if a pinned package has no wheel for Python 3.15. Not added.
RUN echo "*** Installing CTFd Python dependencies ***" && \
  /app/venv/bin/python -m pip install --no-cache-dir -r /app/CTFd/requirements.txt && \
  for req in /app/CTFd/CTFd/plugins/*/requirements.txt; do \
    if [ -f "${req}" ]; then \
      /app/venv/bin/python -m pip install --no-cache-dir -r "${req}"; \
    fi; \
  done && \
  chown -R root:root /app && chmod -R 755 /app && \
  rm -rf /tmp/*

USER apps
COPY --chmod=0755 . /

EXPOSE 8000

VOLUME /config
