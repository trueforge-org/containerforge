# homepage — implementation plan
> Source: ./draft.md · Target: apps/homepage/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | `v2.8.0`, published 2026-11-11. Matches the chart's `ghcr.io/gethomepage/homepage:v2.8.0`. Source: https://api.github.com/repos/gethomepage/homepage/releases/tags/v2.8.0 (via `gh api`). |
| Renovate | `datasource=github-releases depName=gethomepage/homepage versioning=semver`. Tag keeps its `v`; bake `VERSION` = `v2.8.0`. |
| License | GPL-3.0 (GitHub SPDX). `LICENSE` = `GPL-3.0`. |
| Source URL | https://github.com/gethomepage/homepage (the draft's `benphelps/homepage` is the old name; do not use it). |
| Application binary | None. The release has no assets. Build from source. |
| amd64 / arm64 | yes / yes (built from source, Node is arch-neutral). |
| copy-from | no (upstream runner is `node:24-alpine`, musl). |
| Checksum source | None published. Source archive pinned by tag: `https://github.com/gethomepage/homepage/archive/refs/tags/${VERSION}.tar.gz` (standard GitHub URL; confirm it resolves in step 2). |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/gethomepage/homepage/08a0c1df566464bfdb327f3fd8f1f5a058d56640/Dockerfile (the draft pins this commit; the release tag and this commit are not confirmed to be the same tree). |
| Upstream stages | `builder` `node:24-slim` (corepack, pnpm from lockfile, Next.js build with telemetry off, standalone output); runner `node:24-alpine`, copies `public/`, `docker-entrypoint.sh`, `.next/standalone` to `/app`, `.next/static`. |
| Entrypoint | `ENTRYPOINT ["docker-entrypoint.sh"]`, `CMD ["node", "server.js"]`. |
| Env (upstream runner) | `NODE_ENV=production`, `HOSTNAME=::`, `PORT=3000`. Builder: `CI`. |
| Port | `3000/tcp` (`EXPOSE $PORT`). |
| Health | `/api/healthcheck` (upstream HEALTHCHECK every 10 s). |
| Entrypoint behavior | https://raw.githubusercontent.com/gethomepage/homepage/08a0c1df566464bfdb327f3fd8f1f5a058d56640/docker-entrypoint.sh: defaults `PUID`/`PGID` to 0; drops privileges with `su-exec` only when root and `PUID != 0`; creates `/app/config` to `/config` symlink when missing; chowns `/app/config`, `/app/config/logs`, `/app/.next` when `PUID != 0`; sets `HOMEPAGE_BUILDTIME`; defaults `HOSTNAME` to `::` with a fallback to `0.0.0.0`; `exec "$@"`. |
| Config path | Upstream config dir is `/app/config` (symlinked to `/config`). |
| Host check | Next.js checks the Host header. The env name that allows extra hosts is UNVERIFIED (the expected name is `HOMEPAGE_ALLOWED_HOSTS`; confirm in the upstream docs/source before listing it). |
| Dependencies | none. |

## 2. Target layout

- `apps/homepage/Dockerfile`
- `apps/homepage/docker-bake.hcl`
- `apps/homepage/settings.yaml`
- `apps/homepage/container-test.yaml`
- `apps/homepage/start.sh`

No `defaults/` unless the app needs seeded YAML (see section 7). No `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

- Build stage and final stage: `FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5`. It is the existing node-capable base (budge and diskover use it), and budge's Dockerfile notes Node 24 on it. Node is needed at runtime for the Next.js standalone server, so the final stage needs node too.
- Rejected: `ubuntu` plus a separate Node install. More work for no gain, and it would duplicate the python-node base's node.
- Closest sibling: `apps/budge` (python-node, Node build of a web app, `USER apps`, `/config` volume).
- UNVERIFIED: exact Node major in python-node; confirm with `node -v` in step 2 (must be Node 24 to match upstream).

## 4. Dockerfile

1. Stage `builder` from the python-node digest above:
   - `ARG VERSION`, `USER root`.
   - `ENV NEXT_TELEMETRY_DISABLED=1`. Do not set `CI=true`: the upstream Dockerfile skips install and build when `CI` is `true` (it expects a prebuilt app).
   - Fetch the tag source: `curl -fL https://github.com/gethomepage/homepage/archive/refs/tags/${VERSION}.tar.gz | tar xz -C /src --strip-components=1`.
   - `corepack enable`, `corepack prepare pnpm@latest --activate` (or the pnpm version pinned by the repo's `packageManager` field; read it in step 2).
   - In `/src`: `pnpm install --frozen-lockfile`, `pnpm run build` (produces `.next/standalone` and `.next/static`).
   - Set upstream version metadata if the build reads it: the upstream Dockerfile declares `ARG BUILDTIME`, `VERSION` and `REVISION` (confirmed at v2.8.0); how the build consumes them is UNVERIFIED, so check before wiring them.
2. Final stage from the same python-node digest:
   - `USER root`.
   - `COPY --from=builder /src/.next/standalone /app`, `COPY --from=builder /src/.next/static /app/.next/static`, `COPY --from=builder /src/public /app/public`.
   - Build-time symlink (matches upstream's runtime symlink without a runtime write): `ln -s /config /app/config`.
   - Pre-create the Next cache dir as a symlink to `/tmp`: `ln -s /tmp/next-cache /app/.next/cache` (UNVERIFIED that Next writes `.next/cache` at runtime; if the run shows writes there, this is required).
   - `chown -R apps:apps /app && chmod -R 755 /app`.
   - `ENV NODE_ENV=production HOSTNAME=0.0.0.0 PORT=3000 HOME=/config`.
   - `USER apps`, `COPY --chmod=0755 . /`.
   - `EXPOSE 3000`, `VOLUME /config`, `WORKDIR /app`.
   - License: upstream `LICENSE` to `/usr/share/licenses/homepage/LICENSE` from `/src` in the builder.

Do not run `su-exec`, `chown` or `PUID` logic: the image runs as `apps` only, so the upstream entrypoint's privilege handling is not carried over.

## 5. docker-bake.hcl

- `APP` = `homepage`.
- `VERSION` = `v2.8.0` with `// renovate: datasource=github-releases depName=gethomepage/homepage versioning=semver`.
- `LICENSE` = `GPL-3.0`.
- `SOURCE` = `https://github.com/gethomepage/homepage`.
- Standard targets (as `apps/adguardhome-sync/docker-bake.hcl`); `image-local` tags `${APP}:${VERSION}`.
- Validate with `docker buildx bake --print` in `apps/homepage/`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/gethomepage/homepage"
ports:
  - port: 3000
    protocol: tcp
    required: true
env:
  - name: HOSTNAME
    default: "0.0.0.0"
    required: false
  - name: PORT
    default: "3000"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```

- Add `HOMEPAGE_ALLOWED_HOSTS` only after its name is confirmed (section 1, UNVERIFIED). Do not invent it.
- `PUID`/`PGID` are not listed: the image runs as `apps`.

## 7. start.sh

```bash
#!/usr/bin/env bash
set -eu
export HOSTNAME="${HOSTNAME:-0.0.0.0}"
export PORT="${PORT:-3000}"
mkdir -p /config/logs /tmp/next-cache
cd /app
exec node server.js
```

- Idempotent: `mkdir -p` only (`/tmp/next-cache` is the target of the `.next/cache` symlink and must exist at runtime). Homepage creates its own default YAML on first start (UNVERIFIED; confirm in step 3 with an empty `/config`). If it does not, seed the upstream sample configs from `/defaults` into `/config` with `cp -n` (only when missing).
- Never writes to `/app` except through the symlinks above (`/app/config` to `/config`).
- `HOSTNAME` default `0.0.0.0` (the bind rule), not the upstream `::`.
- `exec` for signal handover.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

tcp:
- port: '3000'
http:
- port: '3000'
  path: /api/healthcheck
```

- `tcp` on 3000 (only port in `settings.yaml`).
- `http` on `/api/healthcheck`: the endpoint is confirmed by the upstream HEALTHCHECK. Confirm the 200 response in step 3 before keeping it.
- `timeoutSeconds`: match sibling `apps/budge` (Node web app).
- `filePaths`: none needed unless step 3 shows the first-start config files are created.

## 9. Rootless and read-only-rootfs adaptations

| Upstream | Adapted |
| --- | --- |
| `PUID`/`PGID` and `su-exec` drop | Image runs as `USER apps`; no runtime privilege switch. |
| `/app/config` created at runtime | Symlink `/app/config` to `/config` at build time. |
| `chown -R` on `/app/config`, `/app/.next` | Not run; `/config` is owned by `apps` through the volume. |
| `/app/.next/cache` writes | Symlink to `/tmp/next-cache` (UNVERIFIED need). |
| `HOSTNAME=::` | `0.0.0.0` (bind rule). |
| Chart's `/app/config` pvc and dummy-config configmaps | `/config` volume; no configmap subPath mounts needed. |

Run check: `docker run --read-only --tmpfs /tmp -v homepage-probe-config:/config <image>`.

## 10. Risks, caveats and open questions

- Manual setup: services, widgets and API keys are written by hand into YAML. The image is useless until those files exist; a fresh `/config` shows default content only (UNVERIFIED for this version).
- Host header: recent Next.js rejects unknown host names. The allow-list env name is UNVERIFIED (section 1). Without it, access by a new name fails; document in the PR.
- `.next/cache` writes under read-only rootfs: UNVERIFIED, handled by the `/tmp` symlink in section 4.
- Pinned tag vs commit: the draft pins Dockerfile commit `08a0c1d...`, while the release tag is `v2.8.0` (2026-11-11). The Dockerfile reviewed is the one at that commit; confirm it matches the tag tree in step 2.
- Source-only build: no checksum published. Tag-pinned archive is the only provenance.
- arm64: built from source; not yet tested.
- Blockers: none known. No GPU, no privileged need.

## 11. Build and test steps

1. `cd apps/homepage && docker buildx bake --print` (exit 0).
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`. Confirm `node -v` is 24.x and `pnpm install --frozen-lockfile` succeeds.
3. Probe run: `docker run --rm -d --name homepage-probe --read-only --tmpfs /tmp -v homepage-probe-config:/config homepage:v2.8.0`, then `docker logs -f homepage-probe`. Expected readiness: Next.js "ready" line on port 3000 (wording UNVERIFIED), process still running, no fatal error, and `/api/healthcheck` answers.
4. Test: `forgetool containers test --image homepage:v2.8.0 --config ./apps/homepage/container-test.yaml`.
5. Cleanup: `docker rm -f homepage-probe; docker volume rm homepage-probe-config`.
6. arm64 only if amd64 fails for arch-specific reasons.

## 12. PR checklist

- Branch `feat/add-homepage`, commit and PR title `feat(homepage): add new container`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, check only what applies.
- Notes section must contain `🤖 This PR is AI generated.`
- Tell the user about the CLA (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it.
- Say what was not tested: arm64, the probe run, forgetool test, the allow-host env name, and the Node major if not confirmed.
