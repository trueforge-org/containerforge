# DRAFT, UNRESOLVED (see plan.md section 10):
# - Upstream mozilla-services/syncserver is archived and Python 2.7 only (its Makefile and
#   requirements.txt pin Python 2 packages), so this uses the EOL python:2.7-alpine3.10 base
#   like crazy-max/docker-firefox-syncserver did. There is no ContainerForge Python 2.7 base.
# - No upstream security fixes exist. The successor is mozilla-services/syncstorage-rs (a new app).
# - Source is pinned by commit, there is no published checksum.

FROM docker.io/library/python:2.7-alpine3.10@sha256:aa6542f4f074bba8f048b3e663d46cc7adf24337ca39642b0d1bae743a7e38ef
ARG VERSION
ARG SYNCSERVER_COMMIT=5932c464d70ec9cf0344b1d3e970b3711de6a98e

ENV PYTHONDONTWRITEBYTECODE=1 \
    HOME=/config

USER root

RUN apk add --no-cache bash curl libffi libressl libstdc++ mariadb-client postgresql-client tzdata \
    && apk add --no-cache --virtual build-dependencies build-base gcc libffi-dev libressl-dev mariadb-dev musl-dev postgresql-dev python-dev \
    && mkdir -p /app /usr/share/licenses/firefox-syncserver \
    && curl -fsSL "https://github.com/mozilla-services/syncserver/archive/${SYNCSERVER_COMMIT}.tar.gz" \
        | tar -xz --strip-components=1 -C /app \
    && cd /app \
    && pip install --no-cache-dir --upgrade -r requirements.txt \
    && pip install --no-cache-dir psycopg2 pymysql \
    && python ./setup.py develop \
    && cp LICENSE /usr/share/licenses/firefox-syncserver/ \
    && apk del build-dependencies \
    && addgroup -g 568 apps \
    && adduser -u 568 -G apps -h /config -s /bin/bash -D apps \
    && mkdir -p /config \
    && chown 568:568 /config \
    && chmod -R a+rX /app

COPY --chmod=0755 . /

USER apps
WORKDIR /config
EXPOSE 5000

CMD ["/start.sh"]
