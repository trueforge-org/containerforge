# UNVERIFIED BLOCKER: Mailpile 1.0.0rc6 is Python 2 code. This draft assumes a Python 3 run works in /app/venv; that is not verified.
FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d AS build

ARG VERSION
# UNVERIFIED: no upstream checksum. Compute on the first fetch and pin it in the bake file.
ARG MAILPILE_SHA256

USER root

# Build tools are needed only if a pinned package has no Python 3 wheel (UNVERIFIED). Purged in the same layer.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        libffi-dev \
        libssl-dev \
        libxml2-dev \
        libxslt1-dev \
    && curl -fsSL -o /tmp/mailpile.tar.gz "https://github.com/mailpile/Mailpile/archive/refs/tags/${VERSION}.tar.gz" \
    && echo "${MAILPILE_SHA256}  /tmp/mailpile.tar.gz" | sha256sum -c - \
    && mkdir -p /tmp/src \
    && tar -xzf /tmp/mailpile.tar.gz -C /tmp/src --strip-components=1 \
    && rm -f /tmp/mailpile.tar.gz \
    && /app/venv/bin/pip install --no-cache-dir -r /tmp/src/requirements.txt \
    && mkdir -p /usr/share/licenses/mailpile \
    && cp /tmp/src/COPYING.md /usr/share/licenses/mailpile/COPYING.md \
    && apt-get purge -y --auto-remove build-essential libffi-dev libssl-dev libxml2-dev libxslt1-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d

ENV HOME=/config \
    TZ=Etc/UTC \
    GNUPGHOME=/config/gnupg \
    TMPDIR=/tmp \
    MAILPILE_GNUPG=/usr/bin/gpg \
    MAILPILE_GNUPG/GA=/usr/bin/gpg-agent \
    MAILPILE_GNUPG/DM=/usr/bin/dirmngr \
    MAILPILE_TOR=/usr/bin/tor \
    MAILPILE_OPENSSL=/usr/bin/openssl

USER root

# UNVERIFIED: gnupg1 (used upstream) may not exist on Ubuntu 26.04; add it only if Mailpile needs GnuPG 1.
RUN apt-get update \
    && apt-get install -y --no-install-recommends gnupg tor \
    && rm -rf /var/lib/apt/lists/*

COPY --from=build /tmp/src /app/mailpile
COPY --from=build /app/venv /app/venv
COPY --from=build /usr/share/licenses/mailpile /usr/share/licenses/mailpile
RUN chown -R root:root /app /usr/share/licenses/mailpile \
    && chmod -R 755 /app

USER apps
COPY --chmod=0755 . /

EXPOSE 33411
VOLUME /config
WORKDIR /config
