FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d

ARG VERSION
USER root

# UNVERIFIED: upstream is python:3.8-slim and pins nothing in requirements.txt. Python 3.15
# may not have wheels for every dependency (Pillow, cffi, bcrypt); fix in the build loop.
RUN echo "*** Installing ping ***" && \
  apt-get update && \
  apt-get install -y --no-install-recommends inetutils-ping && \
  rm -rf /var/lib/apt/lists/*

RUN echo "*** Installing DashMachine ${VERSION} ***" && \
  mkdir -p /app/dashmachine && \
  curl -fL -o /tmp/dashmachine.tar.gz \
    "https://github.com/rmountjoy92/DashMachine/archive/refs/tags/${VERSION}.tar.gz" && \
  tar xzf /tmp/dashmachine.tar.gz -C /app/dashmachine --strip-components=1 && \
  /app/venv/bin/pip install -U --no-cache-dir -r /app/dashmachine/requirements.txt && \
  /app/venv/bin/pip install -U --no-cache-dir gunicorn && \
  rm -rf /app/dashmachine/dashmachine/user_data && \
  ln -s /config/user_data /app/dashmachine/dashmachine/user_data && \
  mkdir -p /usr/share/licenses/dashmachine && \
  cp /app/dashmachine/License.md /usr/share/licenses/dashmachine/License.md && \
  echo "*** Cleaning Up ***" && \
  chown -R apps:apps /app && chmod -R 755 /app && \
  rm -rf /tmp/*

# PRODUCTION is set by the upstream image; UNVERIFIED whether the code reads it.
ENV PRODUCTION=true

USER apps
COPY --chmod=0755 . /

EXPOSE 5000

VOLUME /config
WORKDIR /app/dashmachine
