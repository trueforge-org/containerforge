# Upstream Dockerfile: n8n-io/n8n docker/images/n8n

Source URL(s) + date:
- https://raw.githubusercontent.com/n8n-io/n8n/master/docker/images/n8n/Dockerfile (2026-11-27)
- https://raw.githubusercontent.com/n8n-io/n8n/n8n@3.3.0/docker/images/n8n/Dockerfile (raw variant of the blob URL, 2026-11-27)

What it is: upstream image build. Consumes a prebuilt pnpm `./compiled` tree produced by CI, plus base images passed by `docker/docker-bake.hcl` (not fetched). Build with `pnpm build:docker` or `docker buildx bake`, not plain `docker build`.

Build args:
- `N8N_VERSION` (default `snapshot`)
- `BUILDER_IMAGE`, `RUNTIME_IMAGE` (set by bake, values not fetched)
- `ENABLE_POINTER_COMPRESSION` (default `false`)
- `N8N_RELEASE_TYPE` (default `dev`)
- `IMAGE_DESCRIPTION` (default "Workflow Automation Tool")

Stages:
1. `node-source` FROM `${BUILDER_IMAGE}` (source of compiled Node binary)
2. `toolchain` FROM node-source: `apk add python3 make g++`
3. `native-builder`: compiles isolated-vm, sqlite3 (+ tar, node-addon-api deps), @confluentinc/kafka-javascript (`apk add librdkafka-dev`, `BUILD_LIBRDKAFKA=0`)
4. Final FROM `${RUNTIME_IMAGE}`: removes stock node/npm, copies `/usr/local/bin` and `/usr/local/lib` from node-source, verifies node path, V8 `-n8n.N` suffix and pointer-compression flag, symlinks `/usr/bin/node`.

Runtime (final stage):
- `ENV NODE_ENV=production`, `N8N_RELEASE_TYPE`, `SHELL=/bin/sh`, `MAGICK_CODER_STABILITY=PRIMARY`
- `WORKDIR /home/node`
- `COPY ./compiled` -> `/usr/local/lib/node_modules/n8n`; `docker-entrypoint.sh` -> `/`
- Strips GraphicsMagick coders msl, mvg, pcd, svg, url
- `ln -s /usr/local/lib/node_modules/n8n/bin/n8n /usr/local/bin/n8n`
- `mkdir -p /home/node/.n8n`, `chown -R node:node /home/node`, `rm -rf /root/.npm /tmp/*`
- `EXPOSE 5678/tcp`, `USER node`
- `ENTRYPOINT ["tini", "--", "/docker-entrypoint.sh"]`, no CMD, no VOLUME
- LABELs: org.opencontainers.image.title/description/source (https://github.com/n8n-io/n8n)/url (https://n8n.io)/version

Entrypoint flags/env: `docker-entrypoint.sh` not fetched (not in repo fetch list).

Arch: native modules compiled per target (isolated-vm, sqlite3, kafka-javascript); the build needs a compiler stage.

Gotchas:
- Do not `COPY --link` into pnpm symlink destinations (module fails to load).
- Confluent kafka-javascript has no prebuild for CI's Node, so it is compiled in the build.
- `/home/node` is the home for user `node`; `.n8n` lives there upstream.
- Version drift: 3.3.0 tag Dockerfile differs from master (its FROM/ENTRYPOINT/USER/EXPOSE match master's pattern; ~5.5 KB vs ~7 KB on master).
