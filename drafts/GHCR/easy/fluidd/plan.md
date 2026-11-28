# fluidd — implementation plan
> Source: ./draft.md · Target: apps/fluidd/ · Difficulty: easy · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | v1.38.1, published 2026-11-17T15:03:29Z. Source: https://api.github.com/repos/fluidd-core/fluidd/releases/latest. Matches the draft. |
| Renovate | `// renovate: datasource=github-releases depName=fluidd-core/fluidd versioning=semver` (GitHub release tags with a `v` prefix; semver is the default) |
| License | GPL-3.0 (GitHub SPDX `GPL-3.0`; text is GPL v3). Sources: https://api.github.com/repos/fluidd-core/fluidd, https://raw.githubusercontent.com/fluidd-core/fluidd/master/LICENSE |
| Source URL | https://github.com/fluidd-core/fluidd |
| Download | https://github.com/fluidd-core/fluidd/releases/download/v1.38.1/fluidd.zip (arch-independent static files; same for amd64 and arm64) |
| Checksum source | GitHub release asset digest: `sha256:eea2b7e95dbe4b1ddec4fc97547a36fd8aeac411070ad86f6cd77d67ddb57bc6` (from the API) |
| Upstream Dockerfile | https://raw.githubusercontent.com/fluidd-core/fluidd/master/Dockerfile: `ARG BASE_IMAGE=nginx:alpine-slim`, `ARG PORT=80`, `ENV PORT=${PORT}`, `COPY /dist /usr/share/nginx/html`, `COPY /server/nginx /etc/nginx/templates`, HEALTHCHECK `wget http://127.0.0.1:${PORT}/healthz`. No EXPOSE, USER, ENTRYPOINT, CMD (inherited). |
| Upstream nginx config | https://raw.githubusercontent.com/fluidd-core/fluidd/master/server/nginx/default.conf.template: `listen ${PORT} default_server;`, `listen [::]:${PORT} default_server;`, `root /usr/share/nginx/html;`, `location = /healthz { return 200 "ok\n"; }` |
| Env vars (real) | `PORT` (default 80, used by the template). No others found in the fetched files. |
| Ports | 80/tcp upstream default. Our sibling nginx listens on 8080. |
| Data paths | None upstream: static files. The printer endpoint is set in the UI (UNVERIFIED where it is stored). |
| arm64 | Yes: static dist, no native code. |

## 2. Target layout

apps/fluidd/
- Dockerfile (FROM nginx sibling, `USER apps`, `COPY --chmod=0755 . /`)
- docker-bake.hcl
- settings.yaml
- container-test.yaml
- defaults/usr/share/nginx/html/ (the fluidd dist, extracted at build time from the release zip) only if a build-time extract is not possible; prefer extracting in the Dockerfile
- defaults/default.conf: a site file with `root /usr/share/nginx/html;`, `listen 8080`, and `location = /healthz`. The nginx sibling's entrypoint copies `/defaults/default.conf` into `/config/sites/default.conf` with `cp -n`. Replacing this file in `/defaults/` takes effect on first run only, so keep the file name the same as the sibling's.

No start.sh is needed: the nginx sibling's entrypoint and CMD do the work. Add `start.sh` only if a seeding step is needed beyond the nginx entrypoint. No `root/`.

No DOWNSTREAM_CHANGES.md: fluidd is not a FROM base.

## 3. Base image

- FROM `ghcr.io/trueforge-org/nginx:1.28.3@sha256:1e4f20bfcf614853820179bb28127b1375061c09f565bb7010495845d4742c9f`. This is the exact nginx sibling base from the brief. Its runtime user is `apps`, and it listens on 8080.
- Foundation: `ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a`, through nginx.
- Closest sibling: `apps/nginx` (static site server). `apps/it-tools` and `apps/theme-park` are other nginx-served static apps.
- Why not the upstream alpine base: upstream uses `nginx:alpine-slim`, which is musl. The ContainerForge image must be glibc Ubuntu, so the nginx sibling is used instead.

## 4. Dockerfile

1. `FROM` nginx base as in section 3.
2. `ARG VERSION` (must equal `VERSION` in docker-bake.hcl, `v1.38.1` or `1.38.1`; pick one form and keep the URL consistent).
3. `ARG VERSION` is used in the download URL: `https://github.com/fluidd-core/fluidd/releases/download/v${VERSION}/fluidd.zip`. Check the tag form: the release tag is `v1.38.1`.
4. Download and verify, as root for install steps only:
   - `USER root`
   - No apt install needed: `apps/ubuntu/Dockerfile` already installs `unzip`, `curl` and `wget`, and nginx inherits from it (checked).
   - `curl -fsSL -o /tmp/fluidd.zip <URL>`, then `echo "<sha256>  /tmp/fluidd.zip" | sha256sum -c -`. Use the digest from section 1.
   - `unzip -q /tmp/fluidd.zip -d /usr/share/nginx/html && rm -f /tmp/fluidd.zip`. The zip layout (top-level `index.html` vs a `dist/` folder) is UNVERIFIED: check with `unzip -l` at build time and adjust the target path.
5. Ship the licence: `/usr/share/licenses/fluidd/LICENSE` (GPL-3.0 text from the repo).
6. Caches to `/tmp` only.
7. `USER apps` at the end, `COPY --chmod=0755 . /` as the last copy, per the Dockerfile rules.
8. `EXPOSE 8080` (matches the nginx sibling's listen port).
9. Keep the nginx sibling's `CMD` (inherited): `nginx -c /config/nginx.conf -g "daemon off;"`.

## 5. docker-bake.hcl

- `target "docker-metadata-action" {}`
- `variable "APP" { default = "fluidd" }`
- `variable "VERSION"`:
  ```hcl
  // renovate: datasource=github-releases depName=fluidd-core/fluidd versioning=semver
  default = "1.38.1"
  ```
- `variable "LICENSE" { default = "GPL-3.0-only" }`. The repo's SPDX is `GPL-3.0`; confirm the exact identifier the other apps use (for example `AGPL-3.0-or-later` in siblings) and match the repo's licence file.
- `variable "SOURCE" { default = "https://github.com/fluidd-core/fluidd" }`
- `group "default" { targets = ["image-local"] }`, `image`, `image-local` (`output = ["type=docker"]`, tags `${APP}:${VERSION}`), `image-all` with `linux/amd64` and `linux/arm64`.
- Validate: `cd apps/fluidd && docker buildx bake --print`.

## 6. settings.yaml

- Schema header, `schema_version: 1`, `upstream_env_url: "https://github.com/fluidd-core/fluidd"`.
- `ports`:
  ```yaml
  - port: 8080
    protocol: tcp
    required: false
  ```
- `env`:
  - `TZ` (default `Etc/UTC`, required false)
  - Do not add `PORT`: it is not read by the nginx sibling (its config hard-codes 8080). Adding it would be an env var the image ignores.
- `volumes`: `- path: /config`, `required: true` (the nginx sibling's `/config` holds nginx.conf and sites).
- `dependencies`: none. Moonraker/Klipper is a runtime network endpoint configured by the user in the UI, not a ContainerForge dependency.

## 7. start.sh

Not needed. The nginx sibling's entrypoint seeds `/config/nginx.conf` and `/config/sites/default.conf` with `cp -n`. If a start script is added later, it must be idempotent and write only to `/config` and `/tmp`.

## 8. container-test.yaml

- Schema header from `apps/nginx/container-test.yaml`.
- `http:` probe on port `8080`, path `/healthz`, expecting 200 (matches the upstream healthz). Sibling nginx uses `path: /`; add `/healthz` as a second probe, or use `/`. Pick the one that proves the static files are served: a `/` probe plus a `filePaths` check for `/usr/share/nginx/html/index.html` (confirm the path in the build).
- `filePaths`: `/usr/share/nginx/html/index.html` (confirm exact path from the zip listing), `/usr/share/licenses/fluidd/LICENSE`.
- `timeoutSeconds`: 60 (nginx starts fast; compare with `apps/nginx`).
- Every port in settings.yaml (8080) has a probe.

## 9. Rootless and read-only-rootfs adaptations

- The upstream Dockerfile runs nginx on port 80, which a non-root user cannot bind. The nginx sibling listens on 8080, and that is what this image uses.
- `/usr/share/nginx/html` is in the image layer (read-only at runtime, which is fine: fluidd writes nothing there).
- Config lives in `/config` (nginx.conf and sites). Temp paths are `/tmp` (set by the nginx sibling's `nginx.conf`).
- Chart values: the TrueCharts chart runs as root (`runAsNonRoot false`, `runAsUser 0`), and that is out of scope for this repo.
- `readOnlyRootFilesystem`: the image can run read-only with `--tmpfs /tmp` and a `/config` volume. Verify in step 11.
- `privileged`: no.

## 10. Risks, caveats and open questions

- Fluidd is a UI only. It needs a reachable Moonraker/Klipper API, configured by the user (draft, inferred). The image cannot test printer data.
- Port 80 in the upstream image: changed to 8080 here. Users who mapped 80 must update their mapping.
- `cp -n` in the nginx entrypoint: an existing `/config/sites/default.conf` is not overwritten on upgrade, so future changes to the defaults do not reach existing installs. Note in the PR.
- The upstream `ARG PORT` and `HEALTHCHECK` are not carried over: the healthz location exists in the template; the image HEALTHCHECK is not required by the protocol.
- The zip layout is UNVERIFIED until the build; the target directory may need adjusting.
- The nginx sibling's `VERSION` is `1.28.3-2ubuntu1.14` in its bake file; this plan's base is the image digest above, not a re-pinned apt version.
- License identifier: confirm `GPL-3.0-only` vs `GPL-3.0` against the repo's convention before writing docker-bake.hcl.

## 11. Build and test steps

From `apps/fluidd/`:

1. `docker buildx bake --print`
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`
3. `docker run --rm -d --name fluidd-probe --read-only --tmpfs /tmp -v fluidd-probe-config:/config fluidd:1.38.1`, then `docker logs -f fluidd-probe`. Expected readiness: nginx "start worker process" lines and no `[emerg]` or `[crit]`. Then `curl -fsS http://127.0.0.1:8080/` from inside or with a port map.
4. Cleanup: `docker rm -f fluidd-probe; docker volume rm fluidd-probe-config`.
5. `forgetool containers test --image fluidd:1.38.1 --config ./container-test.yaml`.
6. Also run `image-all` (amd64 and arm64) only if the arm64 build is available; the failure of an arm64-only build is recorded, not hidden.

## 12. PR checklist

- Branch: `feat/add-fluidd`
- Commit and PR title: `feat(fluidd): add new container`
- Notes: `🤖 This PR is AI generated.`
- CLA: tell the user to sign at https://cla-assistant.io/trueforge-org/containerforge; only they can sign it.
- PR template: `.github/PULL_REQUEST_TEMPLATE.md`, keep sections, check only what applies.
- Note the port change (80 upstream, 8080 here) and the `cp -n` upgrade behaviour in the PR description.
- Not tested: say so unless steps 2 to 5 passed. Do not check "Built container locally" unless step 2 passed.
