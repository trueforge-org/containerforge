FROM ghcr.io/trueforge-org/python:3.13.7@sha256:87a0f5a9d93409b66626a7de1e66fe7c4d9e1fd037cd4c86e91cc293ebfde78a

ARG TARGETARCH
ARG VENDOR
ARG VERSION

# Derive PG_MAJOR directly from VERSION
ENV LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    PG_MAJOR=${VERSION%%.*} \
    PATH=$PATH:/usr/lib/postgresql/${PG_MAJOR}/bin \
    PGDATA=/data/${PG_MAJOR}

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
    rm -rf /var/lib/apt/lists/* /var/cache/* /var/log/*

# --- Install PostgreSQL (multiple versions) ---
RUN set -eux; \
    PG1=$((PG_MAJOR-1)); \
    apt-get update && \
    apt-get install -y --no-install-recommends \
      -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" \
      "postgresql-${PG1}" \
      "postgresql-${PG_MAJOR}=${VERSION}*" \
      postgresql-server-dev-${PG_MAJOR} && \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false && \
    rm -rf /var/lib/apt/lists/* /var/cache/* /var/log/*

ENV PATH="/usr/lib/postgresql/${PG_MAJOR}/bin:$PATH"

# --- Install additions, extentions, other post-install deps and configure ---
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      ## TODO, enable for 18+ \
      # postgresql-${PG_MAJOR}-jit \
      postgresql-${PG_MAJOR}-pgaudit \
      postgresql-${PG_MAJOR}-pgvector \
      postgresql-${PG_MAJOR}-pg-failover-slots\
      postgresql-server-dev-${PG_MAJOR} \
    && \
    sed -ri 's/#(create_main_cluster) .*$/\1 = false/' /etc/postgresql-common/createcluster.conf && \
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
	grep -F "listen_addresses = '*'" /usr/share/postgresql/postgresql.conf.sample

# --- Install Barman ---
ARG BARMANVERSION
RUN pip3 install --no-cache-dir psycopg2 barman[cloud,azure,snappy,google,zstandard,lz4]==${BARMANVERSION}

# Req from upstream (see: https://github.com/docker-library/postgres/blob/23987751b63ce745bd27b1119ab29dc4a1ffd728/Dockerfile-debian.template#L219)
STOPSIGNAL SIGINT

USER apps

EXPOSE 5432
CMD ["postgres"]
