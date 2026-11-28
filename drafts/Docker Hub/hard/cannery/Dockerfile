# Build stage: Elixir release on Ubuntu (glibc). Upstream builds on Alpine/musl; this image deliberately differs.
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a AS build

ARG VERSION
USER root
WORKDIR /src

# UNVERIFIED: apt Erlang/Elixir versions. Required: Elixir 1.20.5 (mix.exs) and OTP 29.1.2 (.tool-versions).
# Replace with a pinned toolchain if the apt packages do not match. Node 26.13.1 is upstream's asset toolchain;
# the apt nodejs version is UNVERIFIED.
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        curl \
        elixir \
        erlang-dev \
        git \
        nodejs \
        npm \
        openssl; \
    rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    curl -fsSL "https://gitlab.com/shibaobun/cannery/-/archive/${VERSION}/cannery-${VERSION}.tar.gz" \
        | tar xz --strip-components=1 -C /src

# Caches go to /tmp. The build stage is discarded, so only the release is kept.
ENV MIX_ENV=prod \
    HEX_HOME=/tmp/hex \
    MIX_HOME=/tmp/mix \
    npm_config_cache=/tmp/npm

# UNVERIFIED: upstream fetches rebar3 from GitHub with a SHA-512 check. The hash is not in plan.md; add it when pinned.
# heroicons is a git dependency and is fetched from GitHub at build time.
RUN set -eux; \
    mix local.hex --force; \
    mix local.rebar --force; \
    mix deps.get --only prod; \
    npm --prefix ./assets ci --no-audit --loglevel=error; \
    mix assets.deploy; \
    mix release --overwrite; \
    mkdir -p /out/licenses; \
    cp -a _build/prod/rel/cannery /out/app; \
    cp -a priv /out/app/priv; \
    cp LICENSE.md /out/licenses/LICENSE.md; \
    rm -rf /tmp/hex /tmp/mix /tmp/npm

# Final stage
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

USER root

# UNVERIFIED package names on 26.04. Check with ldd on /app/bin/cannery and dpkg before keeping them.
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        libncurses6 \
        libstdc++6 \
        openssl; \
    rm -rf /var/lib/apt/lists/* /tmp/*

COPY --from=build /out/app /app
COPY --from=build /out/licenses /usr/share/licenses/cannery

# Only /config is writable. The release, its priv/ and the helper scripts stay read-only.
ENV HOME=/config \
    RELEASE_TMP=/tmp \
    PORT=4000 \
    UPLOADS_PATH=/config/uploads

USER apps
COPY --chmod=0755 . /

EXPOSE 4000
VOLUME /config

CMD ["/start.sh"]
