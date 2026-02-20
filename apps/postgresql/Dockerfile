FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:36c48bc0fd413c8ef2ae9761b1decc96fa8295f44407a9b7280bd137c2109355

ARG TARGETARCH
ARG VENDOR
ARG VERSION
ARG PG_MAJOR

# Derive PG_MAJOR directly from VERSION
ENV LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    PGDATA=/config/$PG_MAJOR \
    PG_MAJOR=$PG_MAJOR

USER root

# --- Install and configure deps ---
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      postgresql-common \
      locales-all \
      libsasl2-modules \
      libldap-common \
    && \
    /usr/share/postgresql-common/pgdg/apt.postgresql.org.sh -y && \
    echo "Package: postgresql-*\nPin: origin apt.postgresql.org\nPin-Priority: 1001" > /etc/apt/preferences.d/pgdg && \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false && \
    rm -rf /var/lib/apt/lists/* /var/cache/* /var/log/* && \
    sed -ri 's/#(create_main_cluster) .*$/\1 = false/' /etc/postgresql-common/createcluster.conf



# --- Install PostgreSQL (multiple versions) ---
RUN set -eux; \
    PREV_MAJOR=$((PG_MAJOR-1)); \
    apt-get update && \
    apt-get install -y --no-install-recommends \
      -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" \
      "postgresql-${PREV_MAJOR}" \
      "postgresql-${PG_MAJOR}=${VERSION}*" \
      postgresql-server-dev-${PG_MAJOR} && \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false && \
    rm -rf /var/lib/apt/lists/* /var/cache/* /var/log/* && \
    echo "$PREV_MAJOR" >> /PREV_MAJOR

ENV PATH="/usr/lib/postgresql/${PG_MAJOR}/bin:$PATH"

# --- Install additions, extentions, other post-install deps and configure ---
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      postgresql-${PG_MAJOR}-jit \
      postgresql-${PG_MAJOR}-pgaudit \
      postgresql-${PG_MAJOR}-pgvector \
      postgresql-${PG_MAJOR}-pg-failover-slots \
    && \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false && \
    rm -rf /var/lib/apt/lists/* /var/cache/* /var/log/* \
    && \
    postgres --version

# make the sample config easier to munge (and "correct by default")
RUN set -eux; \
	dpkg-divert --add --rename --divert "/usr/share/postgresql/postgresql.conf.sample.dpkg" "/usr/share/postgresql/$PG_MAJOR/postgresql.conf.sample"; \
	cp -v /usr/share/postgresql/postgresql.conf.sample.dpkg /usr/share/postgresql/postgresql.conf.sample; \
	ln -sv ../postgresql.conf.sample "/usr/share/postgresql/$PG_MAJOR/"; \
	sed -ri "s!^#?(listen_addresses)\s*=\s*\S+.*!\1 = '*'!" /usr/share/postgresql/postgresql.conf.sample; \
	grep -F "listen_addresses = '*'" /usr/share/postgresql/postgresql.conf.sample && \
    mkdir -p /var/run/postgresql && \
    chown 568:568 /var/run/postgresql && \
    chmod 03775 /var/run/postgresql

# Req from upstream (see: https://github.com/docker-library/postgres/blob/23987751b63ce745bd27b1119ab29dc4a1ffd728/Dockerfile-debian.template#L219)
STOPSIGNAL SIGINT

USER apps
COPY --chmod=0755 container-test.yaml /container-test.yaml

COPY --chmod=0775 . /


EXPOSE 5432
CMD ["postgres"]
