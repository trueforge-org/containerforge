# UNVERIFIED: digest for haxe:4.3-alpine3.22 not fetched; pin it with `docker buildx imagetools inspect` before merge.
FROM haxe:4.3-alpine3.22@sha256:98ef841bd72a58302092845a99f6f09b7b671ce5d669fd5cbf1483bf758d2a19 AS build

ARG VERSION

# build stage: upstream toolchain (musl alpine); output is arch-neutral JavaScript
RUN apk add --no-cache nodejs npm git ca-certificates wget tar

WORKDIR /src
RUN wget -qO- "https://github.com/RblSb/SyncTube/archive/${VERSION}.tar.gz" | tar -xz --strip-components=1 -C /src
RUN npm ci
RUN haxelib setup /src/haxelib && haxelib install all --always && haxe build-all.hxml
RUN rm -rf /src/.git

FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5

ARG VERSION
USER root

RUN mkdir -p /app /config && \
  chown -R apps:apps /app /config && \
  chmod -R 755 /app && \
  ln -s /config/user /app/user

# UNVERIFIED runtime dirs: upstream Dockerfile copies res, src, user, build-*.hxml, package*.json and default-config.json.
# The plan lists public/; confirm against the source tree after the first download.
COPY --from=build --chown=apps:apps /src/build /app/build
COPY --from=build --chown=apps:apps /src/node_modules /app/node_modules
COPY --from=build --chown=apps:apps /src/package.json /app/package.json
COPY --from=build --chown=apps:apps /src/res /app/res
COPY --from=build --chown=apps:apps /src/default-config.json /app/default-config.json

USER apps
COPY --chmod=0755 . /

EXPOSE 4200/tcp

VOLUME /config
