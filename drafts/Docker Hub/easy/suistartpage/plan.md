# suistartpage — implementation plan
> Source: ./draft.md · Target: apps/suistartpage/ · Difficulty: easy · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | No releases or tags upstream. Pin the last commit on `master`: `fb4094a047d25cd21352c0849b5b623171e7974c` (short `fb4094a`, 2020-05-20, "Update README.md"; the draft's Dockerfile link points at this same commit). The draft's `master.zip` link is floating, so do not use it. |
| Renovate | `datasource=git-refs depName=https://github.com/CorneliousJD/SUI-Startpage currentValue=master` (same pattern as `apps/tvheadend`). The last commit is from 2020, so the repo is effectively dormant. |
| License | Unlicense (`LICENSE` begins "This is free and unencumbered software released into the public domain"). The repo also has a `License.md`, which is blank at the pinned commit. GitHub reports `Unlicense`. SPDX: `Unlicense`. |
| Source URL | https://github.com/CorneliousJD/SUI-Startpage |
| Download (both arches, arch-independent static site) | `https://github.com/CorneliousJD/SUI-Startpage/archive/<full-sha>.tar.gz` (HTTP 200 checked) |
| Checksum source | None published (no release assets). Integrity comes from pinning the full commit SHA in the URL. |
| Upstream Dockerfile reviewed | `FROM nginx:alpine`, `EXPOSE 80`, copies the repo to `/usr/share/holding`, and `start.sh` copies the files into `/usr/share/nginx/html`, then runs `chmod -R 777` and `nginx -g "daemon off;"`. This is only a holding-directory trick for volume mounts and is not needed here. |
| Site contents | `index.html`, `apps.json`, `links.json`, `providers.json`, `favicon.ico`, `assets/` (JS and CSS). Also `LICENSE`, `License.md`, `README.md`, `Dockerfile` and `start.sh`, which are not served. |
| Listening port | The nginx base image serves on **8080**, not the draft's 80. |
| Config | None at runtime. Users customise by replacing `apps.json`, `links.json` and `providers.json` with bind mounts, for example at `/usr/share/nginx/html/apps.json`. |

## 2. Target layout

```
apps/suistartpage/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
```

No `start.sh`: the nginx base image has its own entrypoint and `CMD`, which also seed `/config/nginx.conf` and `/config/sites/default.conf` through `docker-entrypoint.d`. No `defaults/` or `etc/` is needed because the base `default.conf` already serves `/usr/share/nginx/html` on 8080. Never use `root/`. No `DOWNSTREAM_CHANGES.md`, since nothing uses this image as a `FROM` base.

## 3. Base image

`FROM ghcr.io/trueforge-org/nginx:1.28.3@sha256:3a862278083a33d9ff969e987ee3a6ab24d2b928c35df07b2e69fa6f5d4e6cc1`

It is a static site, so no runtime beyond nginx is needed. Closest siblings: `apps/theme-park` (static files copied into `/usr/share/nginx/html`) and `apps/it-tools`. The base is already ubuntu based, so `curl`, `tar` and `ca-certificates` are present and no apt install is needed.

## 4. Dockerfile

1. `FROM` the nginx base (section 3).
2. `ARG VERSION` (the full commit SHA, same value as in `docker-bake.hcl`). No `TARGETARCH` is needed.
3. `USER root` for the install step only.
4. One `RUN` layer:
   ```sh
   curl -fsSL "https://github.com/CorneliousJD/SUI-Startpage/archive/${VERSION}.tar.gz" -o /tmp/sui.tar.gz
   mkdir -p /tmp/sui && tar xzf /tmp/sui.tar.gz -C /tmp/sui --strip-components=1
   rm -rf /usr/share/nginx/html/*
   cp -r /tmp/sui/assets /tmp/sui/index.html /tmp/sui/apps.json /tmp/sui/links.json \
         /tmp/sui/providers.json /tmp/sui/favicon.ico /usr/share/nginx/html/
   mkdir -p /usr/share/licenses/suistartpage
   cp /tmp/sui/LICENSE /usr/share/licenses/suistartpage/
   chown -R 568:568 /usr/share/nginx/html
   chmod -R u=rwX,go=rX /usr/share/nginx/html
   rm -rf /tmp/sui /tmp/sui.tar.gz
   ```
   Never `chmod 777` (upstream does). Copy only the served files, so `Dockerfile`, `start.sh` and `README.md` stay out.
5. `USER apps`, `COPY --chmod=0755 . /`, `VOLUME /config`, `WORKDIR /usr/share/nginx/html` (`apps/theme-park` ending plus the volume).
6. No `EXPOSE` or `CMD` of its own, since both are inherited (`apps/nginx/Dockerfile` declares `EXPOSE 8080` and the `CMD`). The site itself has no state; `VOLUME /config` holds the nginx config that the base seeds (the nginx base does not declare the volume).
7. No apt packages (the draft's `unzip` guess is not needed because upstream publishes a tarball).

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}
variable "APP"     { default = "suistartpage" }
variable "VERSION" {
  // renovate: datasource=git-refs depName=https://github.com/CorneliousJD/SUI-Startpage currentValue=master
  default = "fb4094a047d25cd21352c0849b5b623171e7974c"
}
variable "LICENSE" { default = "Unlicense" }
variable "SOURCE"  { default = "https://github.com/CorneliousJD/SUI-Startpage" }
```

Then add the standard `group "default" { targets = ["image-local"] }` and the targets `image` (`args.VERSION`, labels `org.opencontainers.image.source` and `.licenses`), `image-local` (`output = ["type=docker"]`, tags `${APP}:${VERSION}`) and `image-all` (`linux/amd64`, `linux/arm64`), copied from `apps/adguardhome-sync/docker-bake.hcl`. A 40-character SHA makes an ugly image tag. If maintainers prefer, tag with a short SHA (`fb4094a`) and use a 7-character `ARG`. Archive URLs accept short SHAs, but the full SHA is safer. Run `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/CorneliousJD/SUI-Startpage"
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
```

The app reads no env vars of its own. `TZ` matches the `apps/theme-park` sibling. `/config` holds the nginx config seeded by the base. Dependencies: none (omit the section, as `apps/theme-park` does).

## 7. start.sh

Not applicable: the nginx base's entrypoint (`docker-entrypoint.d/03-copyconfig.sh`) already seeds `/config/nginx.conf` and `/config/sites/default.conf` with `cp -n` and starts `nginx -c /config/nginx.conf -g "daemon off;"` on `0.0.0.0:8080`. Add a `docker-entrypoint.d` script only if the base default config proves insufficient (it should not, because the site is plain static files).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

http:
- port: '8080'
  path: /

filePaths:
- /usr/share/nginx/html/index.html
- /usr/share/nginx/html/apps.json
- /usr/share/licenses/suistartpage/LICENSE
```

The HTTP probe covers the only port in `settings.yaml`. `timeoutSeconds` is omitted, like `apps/theme-park` and `apps/it-tools`. No env is required, and no database is involved, so the narrowing exception is not used.

## 9. Rootless and read-only-rootfs adaptations

| Upstream behaviour | Remap |
|---|---|
| Upstream runs nginx as root on port 80, and `start.sh` writes into `/usr/share/nginx/html` at start with `chmod 777`. | The site is baked in at build time, owned by 568 and read-only at runtime, and nginx runs as `apps` on 8080. |
| nginx temp, cache and pid paths | Already set to `/tmp` by the base `nginx.conf`. |
| TrueCharts: `runAsUser 0`, `readOnlyRootFilesystem false`, extra PVC at `/usr/share/nginx/html` | Reconciled: UID 568 (`USER apps`), read-only rootfs works with `--tmpfs /tmp`, and port 8080 replaces 80, so the chart needs a service-port change. The PVC at `/usr/share/nginx/html` must be dropped, because it would hide the baked-in site. Custom JSON is supplied with file-level mounts instead. |

## 10. Risks, caveats and open questions

- The draft says the image content is unpinned master. This is resolved by pinning the commit SHA. The repo has been dormant since 2020, so there will be no updates, and renovate `git-refs` will stay quiet.
- The draft says port 80. It is 8080 with the ContainerForge nginx base, so document this for chart migration.
- The user's changes are lost on rebuild unless they mount their own `apps.json`, `links.json` or `providers.json` (draft caveat). Mounting over a read-only path is fine.
- `index.html` loads jQuery, Handlebars, Iconify and a Google Font from public CDNs, so the browser needs internet access; the automated test does not cover this.
- No blockers: no arm64 problem (static files), no GPU, no privileged mode.

## 11. Build and test steps

```sh
cd apps/suistartpage
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name suistartpage-probe --read-only --tmpfs /tmp -p 8080:8080 \
  -v suistartpage-probe-config:/config suistartpage:<VERSION>
docker logs -f suistartpage-probe          # no fatal errors, nginx stays up
curl -fsS http://localhost:8080/ | head
docker rm -f suistartpage-probe; docker volume rm suistartpage-probe-config
forgetool containers test --image suistartpage:<VERSION> --config ./apps/suistartpage/container-test.yaml
```

Readiness signal: nginx starts without errors (nginx does not log "ready"), port 8080 answers HTTP 200, and the page contains the SUI markup. Optionally rerun with `--platform linux/arm64`.

## 12. PR checklist

- Branch `feat/add-suistartpage`, commit and PR title `feat(suistartpage): add new container`, target `main`.
- Fill in `.github/PULL_REQUEST_TEMPLATE.md`, keeping its sections and checking only the boxes that apply.
- Put `🤖 This PR is AI generated.` in the Notes section.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge. Only the user can sign it, and the `license/cla` check shows the status.
- Untested at planning time: the image build, the run on a read-only rootfs, `forgetool containers test`, and arm64. Do not check "Built container locally" unless the build was actually done.
