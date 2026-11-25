# tagspaces — implementation plan
> Source: ./draft.md · Target: apps/tagspaces/ · Difficulty: easy · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | **6.15.1** (released 2026-11-16, tag `v6.15.1`). The draft's 6.0.2 is stale. |
| Renovate | `datasource=github-releases depName=tagspaces/tagspaces versioning=semver` |
| License | AGPL v3 (`web/LICENSE.txt` inside the web zip is the AGPL v3 text). TagSpaces is dual-licensed, and the Pro components are proprietary. UNVERIFIED: `-only` or `-or-later`. Use `AGPL-3.0-only` unless the source headers say otherwise. |
| Source URL | https://github.com/tagspaces/tagspaces (docs: https://docs.tagspaces.org/) |
| Download (both arches, arch-independent static bundle) | `https://github.com/tagspaces/tagspaces/releases/download/v6.15.1/tagspaces-web-6.15.1.zip` (HTTP 200, 24.5 MB). The draft's `.deb` and mac-zip links are **not needed**: the web bundle is a release asset. `tagspaces-pro-web-*.zip` is the proprietary Pro build and must not be used. |
| Checksum source | `https://github.com/tagspaces/tagspaces/releases/download/v6.15.1/SHA256SUMS.txt` lists `acf12dec868bf9c5aa5008274735f8342723fda1ff2cbb73a6c0dcd389a5cfb5  tagspaces-web-6.15.1.zip`, and the downloaded zip matches. |
| Zip layout | A single top-level `web/` directory with `index.html`, `dist/`, `assets/`, `modules/`, `extconfig.js`, `manifest.json`, `sw.js` and `LICENSE.txt`, plus `*.LICENSE.txt` third-party notices. |
| Upstream Dockerfile reviewed | `fardjad/tagspaces-lite-docker` (the draft's image, archived by its author and therefore read-only): unzips `tagspaces-web.zip` and copies `web` into `nginxinc/nginx-unprivileged:stable`, `EXPOSE 8080`. We do the same with the ContainerForge nginx base, directly from the official release. |
| Runtime | A static web client served by nginx on port 8080. There are no server env vars. Storage is in the browser (and in remote locations the user configures), so there is no server-side workspace to mount. The draft's "workspace path must be mounted" caveat does not apply to the lite web build. |

## 2. Target layout

```
apps/tagspaces/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
```

No `start.sh`, `defaults/` or `etc/`: the nginx base entrypoint seeds `/config/nginx.conf` and `/config/sites/default.conf`, and the base `default.conf` serves `/usr/share/nginx/html` on 8080. Never use `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/nginx:1.28.3@sha256:1e4f20bfcf614853820179bb28127b1375061c09f565bb7010495845d4742c9f`

It is a static bundle, so nothing else is needed. Closest sibling: `apps/theme-park`. The base has `curl`, `unzip` (installed in the ubuntu base) and `sha256sum` (coreutils).

## 4. Dockerfile

1. `FROM` the nginx base.
2. `ARG VERSION` (default in bake: `6.15.1`).
3. `USER root` for the install only.
4. One `RUN`:
   ```sh
   curl -fsSL -o /tmp/ts.zip "https://github.com/tagspaces/tagspaces/releases/download/v${VERSION}/tagspaces-web-${VERSION}.zip"
   curl -fsSL -o /tmp/SHA256SUMS.txt "https://github.com/tagspaces/tagspaces/releases/download/v${VERSION}/SHA256SUMS.txt"
   (cd /tmp && grep " tagspaces-web-${VERSION}.zip\$" SHA256SUMS.txt | sha256sum -c -)
   unzip -q /tmp/ts.zip -d /tmp/ts
   rm -rf /usr/share/nginx/html/*
   cp -r /tmp/ts/web/. /usr/share/nginx/html/
   mkdir -p /usr/share/licenses/tagspaces
   cp /tmp/ts/web/LICENSE.txt /usr/share/licenses/tagspaces/
   chown -R 568:568 /usr/share/nginx/html
   rm -rf /tmp/ts /tmp/ts.zip /tmp/SHA256SUMS.txt
   ```
   The `grep` anchors on the file name, because `SHA256SUMS.txt` also lists `tagspaces-pro-web-*.zip`. Keep the zip's own `LICENSE.txt` and the `*.LICENSE.txt` notices in the served tree, since they belong to the bundled code.
5. `USER apps`, `COPY --chmod=0755 . /`, `VOLUME /config`, `WORKDIR /usr/share/nginx/html`.
6. Inherit `EXPOSE 8080` and `CMD` from the base (add `EXPOSE 8080` if `docker inspect` shows it missing). `VOLUME /config` (step 5) is needed because the base seeds nginx config there but does not declare the volume. No arch mapping is needed (`TARGETARCH` is not used) and no apt packages are needed.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}
variable "APP" { default = "tagspaces" }
variable "VERSION" {
  // renovate: datasource=github-releases depName=tagspaces/tagspaces versioning=semver
  default = "6.15.1"
}
variable "LICENSE" { default = "AGPL-3.0-only" }
variable "SOURCE"  { default = "https://github.com/tagspaces/tagspaces" }
```

Add the standard `group "default"` and the targets `image`, `image-local` and `image-all` (amd64 and arm64), copied from `apps/adguardhome-sync/docker-bake.hcl`. This copies the exemplar's `v${VERSION}` convention, where the bake version has no `v` and the URL adds it. Run `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/tagspaces/tagspaces"
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

No app-specific env: the web client reads none. Dependencies: none.

## 7. start.sh

Not applicable: nginx starts through the base entrypoint and `CMD`, and seeds `/config/nginx.conf` and `/config/sites/default.conf` idempotently with `cp -n`. It listens on `0.0.0.0:8080`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

http:
- port: '8080'
  path: /

filePaths:
- /usr/share/nginx/html/index.html
- /usr/share/nginx/html/extconfig.js
- /usr/share/licenses/tagspaces/LICENSE.txt
```

The HTTP probe covers the only port. No env is required, and no database is involved.

## 9. Rootless and read-only-rootfs adaptations

| Item | Handling |
|---|---|
| Writes at runtime | nginx writes pid, temp and cache under `/tmp` (set by the base `nginx.conf`). The bundle in `/usr/share/nginx/html` is read-only. |
| TrueCharts: UID 568, `readOnlyRootFilesystem false`, emptyDir `/var/cache/nginx` | Reconciled: UID 568 matches. A read-only rootfs works with `--tmpfs /tmp`, and the emptyDir at `/var/cache/nginx` is not needed because the base caches in `/tmp`. |
| Runtime configuration | `extconfig.js` is part of the bundle, so users who customise it must mount a file over it. |

## 10. Risks, caveats and open questions

- The draft caveat about the arm64 mac zip is resolved: the web zip is arch-independent, so both arches work.
- Version drift: the draft pinned 6.0.2 from a third-party image, which is now archived. The plan tracks upstream releases (6.15.1) directly.
- The web bundle is a PWA with a service worker (`sw.js`) and, in browsers, needs a secure context (HTTPS or localhost) for some features. Mention this in the PR.
- UNVERIFIED: whether upstream's web zip expects specific nginx headers or a SPA fallback. The upstream docker image uses the default nginx config, so the base `default.conf` should be enough. Test by loading the page in a browser.
- UNVERIFIED: the AGPL SPDX variant (see section 1; `package.json` says `AGPL-3.0` and `LICENSING.md` says "version 3 (AGPL-3.0)"; source file headers were not read). `LICENSING.md` states that Lite builds contain only the AGPL core. UNVERIFIED that the non-Pro web zip counts as a Lite build in that sense (the contents were not audited).
- No blockers (no GPU, no privileged mode, no musl-only code).

## 11. Build and test steps

```sh
cd apps/tagspaces
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name tagspaces-probe --read-only --tmpfs /tmp \
  -v tagspaces-probe-config:/config -p 8080:8080 tagspaces:6.15.1
docker logs -f tagspaces-probe
curl -fsS http://localhost:8080/ | head
docker rm -f tagspaces-probe; docker volume rm tagspaces-probe-config
forgetool containers test --image tagspaces:6.15.1 --config ./apps/tagspaces/container-test.yaml
```

Readiness signal: nginx is running without errors, and `GET /` returns 200 with the TagSpaces `index.html`. Optionally rerun with arm64.

## 12. PR checklist

- Branch `feat/add-tagspaces`, commit and PR title `feat(tagspaces): add new container`, target `main`.
- Fill in `.github/PULL_REQUEST_TEMPLATE.md` and check only the boxes that apply.
- Put `🤖 This PR is AI generated.` in the Notes section.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge. Only the user can sign it.
- Untested at planning time: the image build, the read-only run, `forgetool containers test`, arm64, and a browser check of the UI. The checksum match was verified by hand on a downloaded zip.
