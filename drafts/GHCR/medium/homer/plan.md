# homer — implementation plan
> Source: ./draft.md · Target: apps/homer/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | Latest stable release `v26.11.4`, published 2026-11-19 (https://github.com/homer-dashboard/homer/releases/tag/v26.11.4). The draft's chart tag `v26.11.2` (published 2026-11-10) is one release behind. Plan pins `v26.11.4`; the tag is a Renovate-tracked value. |
| Renovate | `datasource=github-releases depName=homer-dashboard/homer versioning=loose` (tags are `vYY.MM.N`, not strict semver, so `loose` per the bake rules) |
| License | Apache-2.0 (GitHub API, `repos/homer-dashboard/homer` spdx_id `Apache-2.0`; the draft's source link is https://github.com/homer-dashboard/homer) |
| Source URL | https://github.com/homer-dashboard/homer |
| Binary asset | `https://github.com/homer-dashboard/homer/releases/download/v26.11.4/homer.zip` (the only release asset; the built static site, arch-neutral) |
| Checksum source | None published as a release asset. UNVERIFIED: no `SHA256SUMS` file seen; the plan pins the tag and records the sha256 of the downloaded zip in the Dockerfile after first download. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/bastienwirtz/homer/b3f7fd87813ce4ea9c4ab91f9ffdca81c7e19db2/Dockerfile: build stage `node:24-alpine3.23` (pnpm 10, `pnpm build`), runtime `alpine:3.23` + lighttpd, `USER ${UID}:${GID}` (1000:1000), `EXPOSE ${PORT}` (8080), `ENTRYPOINT ["/bin/sh","/entrypoint.sh"]`, no VOLUME. |
| Upstream entrypoint reviewed | `entrypoint.sh`: when `INIT_ASSETS=1` and `/www/assets/config.yml` is missing, copies `/www/default-assets/*` into `/www/assets/` and `config.yml.dist` to `config.yml`, then `exec lighttpd -D -f /lighttpd.conf`. |
| Upstream lighttpd.conf reviewed | `server.port = env.PORT`, `server.document-root = /www`, `alias.url = (env.SUBFOLDER => /www)`, `Cache-Control: public, max-age=31536000, immutable` for `/resources/`, `no-cache` elsewhere. |
| Port | 8080/tcp (`PORT` default 8080 in upstream Dockerfile and lighttpd.conf) |
| Env vars the upstream app reads | `PORT` (8080), `SUBFOLDER` (`/_`), `INIT_ASSETS` (1), `IPV6_DISABLE` (0), `UID`/`GID` (1000). These belong to the upstream lighttpd image; see section 6 for which ones ContainerForge keeps. |
| Data/config write paths | `/www/assets` (holds `config.yml` and default assets; chart mounts it as a PVC). The web app itself writes nothing. |
| arm64 | Artifact is arch-neutral static files, so arm64 is supported by construction. UNVERIFIED: published ghcr.io image manifest architectures were not checked. |
| Dependencies | None |
| Blockers | None |

## 2. Target layout

- `apps/homer/Dockerfile`
- `apps/homer/docker-bake.hcl`
- `apps/homer/settings.yaml`
- `apps/homer/container-test.yaml`
- `apps/homer/start.sh`
- `apps/homer/defaults/config/homer.conf` is NOT needed if the nginx sibling's site include directory is used; see section 4 step 5 (`defaults/` only for the seed `config.yml.dist` and the nginx site file, with reason: the site file is seeded to `/config` because `/config/sites/*.conf` is where the nginx base includes site configs).

No `root/`. No `DOWNSTREAM_CHANGES.md` (homer is not a `FROM` base). No `etc/` (site config goes under `defaults/`).

## 3. Base image

Runtime: `FROM ghcr.io/trueforge-org/nginx:1.28.3@sha256:1e4f20bfcf614853820179bb28127b1375061c09f565bb7010495845d4742c9f` (UNVERIFIED: the tag and digest are not in the repo, `apps/nginx` is built from the apt version `1.28.3-2ubuntu1.14` on the same ubuntu digest; check the published image). It serves the static site, matching the draft's nginx runtime. The nginx sibling runs as `USER apps`, listens on 8080 by default and `CMD`s `nginx -c /config/nginx.conf -g 'daemon off;'`; its `docker-entrypoint.d/03-copyconfig.sh` seeds `/config/nginx.conf` and `/config/sites/default.conf` before `/start.sh` runs (the ubuntu entrypoint runs `/start.sh "$@"`).

Build stage (only unzip is needed, the site is pre-built upstream): `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a`.

Closest sibling: `apps/nginx` (runtime). The upstream pnpm build is not repeated, because the release asset already contains `dist`.

## 4. Dockerfile

1. Build stage: `FROM <ubuntu> AS build`, `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. No apt install needed: `apps/ubuntu/Dockerfile` already installs `unzip`, `curl` and `tar`.
3. `curl -fL -o /tmp/homer.zip https://github.com/homer-dashboard/homer/releases/download/${VERSION}/homer.zip`, then `unzip -q /tmp/homer.zip -d /tmp/homer`. Verify with a sha256 pin (`ARG HOMER_SHA256`), since no upstream checksum exists. Set the pin from the first download and state that in the PR.
4. Final stage: `FROM ghcr.io/trueforge-org/nginx@sha256:...`, `ARG VERSION`, `USER root`.
5. `mkdir -p /app/www && cp -r /tmp/homer/. /app/www/ && mv /app/www/assets /app/www/default-assets`. The site root is `/app/www`, read-only at runtime. The upstream `assets` folder is kept as `default-assets` so `start.sh` can seed from it.
6. Copy the nginx site include to a seed location: `COPY --chmod=0755 ./ /` brings `defaults/` into the image. `start.sh` copies `defaults/sites/homer.conf` into `/config/sites/` only when missing.
7. `ln -s /config/assets /app/www/assets` is a dangling symlink until `start.sh` seeds `/config/assets`; this is the same pattern as `apps/bookstack` (`rm -rf` the target, then `ln -s /config/...`).
8. The build stage is discarded; the final stage must copy the site with `COPY --from=build /tmp/homer/ /app/www/` instead of relying on `/tmp` of the final stage (steps 5 and 7 then run in the final stage after the COPY). Also ship the license: `COPY --from=build` upstream `LICENSE` if present in the zip (UNVERIFIED) to `/usr/share/licenses/homer/`.
9. `ENV TZ=Etc/UTC`.
10. Tail (copy the nginx sibling's pattern):

```dockerfile
EXPOSE 8080
VOLUME /config
USER apps
COPY --chmod=0755 . /
```

The nginx sibling sets `CMD ["nginx", "-c","/config/nginx.conf", "-g", "daemon off;"]`. Keep it, and do not override it.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "homer"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=homer-dashboard/homer versioning=loose
  default = "v26.11.4"
}

variable "LICENSE" {
  default = "Apache-2.0"
}

variable "SOURCE" {
  default = "https://github.com/homer-dashboard/homer"
}
```

Then the four standard targets and the `default` group copied from `apps/bookstack/docker-bake.hcl`. Run `docker buildx bake --print` from `apps/homer/`. The Dockerfile `ARG VERSION` must equal the default above (including the `v` prefix, because it is used in the release URL).

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/homer-dashboard/homer"
ports:
  - port: 8080
    protocol: tcp
    required: false
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```

Upstream env vars `PORT`, `SUBFOLDER`, `INIT_ASSETS` and `IPV6_DISABLE` belong to the lighttpd image that ContainerForge does not use, so they are not listed (the rule is not to invent env vars). `SUBFOLDER` support is an open question in section 10.

## 7. start.sh

```bash
#!/usr/bin/env bash

mkdir -p /config/assets /config/sites

if [[ ! -f /config/sites/homer.conf ]]; then
    cp /defaults/sites/homer.conf /config/sites/homer.conf
fi

if [[ ! -f /config/assets/config.yml ]]; then
    cp -n /app/www/default-assets/config.yml.dist /config/assets/config.yml 2>/dev/null || true
    cp -Rn /app/www/default-assets/. /config/assets/ 2>/dev/null || true
fi

exec "$@"
```

Notes: idempotent, seeds only when missing, no write to `/app`. `/app/www/default-assets` is a copy of upstream `dist/assets` (the Dockerfile must copy it there, see step 5), so the path must exist in the image. `exec "$@"` hands PID 1 to the nginx `CMD`. Do not `exec` a hard-coded command here, which would break the base `CMD`. Caching or scratch goes to `/tmp` (nginx base already sets `/tmp/nginx-temp`).

Because `/app/www/assets` is a symlink to `/config/assets`, the `config.yml` path the app reads stays valid. Verify in the run that homer loads `/assets/config.yml` through that link (UNVERIFIED).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 60
tcp:
- port: '8080'
http:
- port: '8080'
  path: /
filePaths:
- /app/www/index.html
- /app/www/assets
- /config/sites/homer.conf
```

`tcp` and `http` both target 8080 (the only port in `settings.yaml`). `/config/sites/homer.conf` is seeded by `start.sh`, so it exists after start. Without `start.sh` run in the test, that path is only checked after start; if forgetool runs the entrypoint, it passes, otherwise drop that entry and add a log-based check (UNVERIFIED how forgetool orders this).

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/www/assets` (config.yml, user assets) | `/app/www/assets` -> `/config/assets` symlink, seeded by `start.sh` |
| lighttpd logs (`/dev/fd/3`) | Not used; nginx base logs to `/dev/stdout` and `/dev/stderr` |
| nginx temp and cache | `/tmp/nginx-temp`, `/tmp/nginx-cache` (set by nginx base) |

Upstream runs as UID/GID 1000 (`USER ${UID}:${GID}`). ContainerForge runs as `apps` (`USER apps`), which the nginx base provides. The draft expected `runAsUser 1000`, `readOnlyRootFilesystem true` and `privileged false`; these are compatible. Confirm `--read-only --tmpfs /tmp` works (section 11).

## 10. Risks, caveats and open questions

- Version: the draft's `v26.11.2` is outdated; the plan uses `v26.11.4`. Confirm the Homer config format is unchanged between the two.
- Site config: the nginx base's `defaults/default.conf` listens on 8080 as `default_server` and roots at `/usr/share/nginx/html`. The site file at `/config/sites/homer.conf` must not clash with that `default_server`. UNVERIFIED: whether the `default.conf` include and `/config/sites/*.conf` both load, and whether the root `default.conf` is shadowed. Check in the run; if it clashes, drop the `listen` line from the site file or use a different server name.
- `SUBFOLDER`: the chart and upstream support a sub-path; ContainerForge does not expose it. Flag as a known gap.
- No login: the dashboard has no auth; the caveat in the draft is unchanged.
- Checksum: upstream publishes none; the sha256 pin is ContainerForge's own.
- Blockers: none (no musl-only, GPU, privileged, or arm64 gap).

## 11. Build and test steps

```sh
cd apps/homer
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name homer-probe --read-only --tmpfs /tmp \
  -v homer-probe-config:/config homer:v26.11.4
docker logs -f homer-probe
forgetool containers test --image homer:v26.11.4 --config ./apps/homer/container-test.yaml
docker rm -f homer-probe; docker volume rm homer-probe-config
```

Expected readiness signal: nginx logs `start worker process` and the container stays up. Check `curl -sf http://localhost:8080/` returns the Homer page, and that `/config/assets/config.yml` exists after start. Restart and confirm the existing `config.yml` is kept. Test from outside the container (`-p 8080:8080`) to confirm the listen address is not localhost only.

## 12. PR checklist

- Branch `feat/add-homer`, commit and PR title `feat(homer): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections, check only what applies.
- Notes section includes `🤖 This PR is AI generated.`
- CLA: a signed Contributor License Agreement is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it; the `license/cla` check shows status.
- Untested to state honestly: arm64 build, read-only run, nginx site include behaviour, `SUBFOLDER` (not supported), and the sha256 pin's first-download value.
- `docker buildx bake --print` passes; bake `VERSION` equals Dockerfile `ARG VERSION`; no assertion weakened.
