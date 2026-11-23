# keeweb — implementation plan
> Source: ./draft.md · Target: apps/keeweb/ · Difficulty: easy · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | `1.18.7` (tag `v1.18.7`, 2021-07-18). This is the latest non-prerelease. `v1.18.8` and `v1.18.9` (2026-05) exist on GitHub but are flagged prerelease, and `v1.18.8` has no assets. The draft links the same `v1.18.7`. The Docker Hub image `antelle/keeweb:latest` was last pushed 2021-07-18, so it is the same release. |
| Renovate | `datasource=github-releases depName=keeweb/keeweb versioning=semver` (prereleases are skipped by default, so renovate stays on 1.18.7 until a stable release appears). |
| License | `MIT` (`LICENSE`: "MIT License, Copyright (c) 2021 Antelle"). GitHub reports `NOASSERTION` only because of the file header. |
| Source (`SOURCE`) | https://github.com/keeweb/keeweb |
| What it is | A client-side single-page app (one `index.html` of ~1.6 MB). There is no server-side code, so one artifact serves amd64 and arm64. |
| Download (both arches) | `https://github.com/keeweb/keeweb/releases/download/v1.18.7/KeeWeb-1.18.7.html.zip`. It unpacks to `index.html`, `manifest.json`, `update.json`, `404.html`, `service-worker.js`, `browserconfig.xml`, `icons/` and `oauth-result/`. |
| Draft correction | The draft's amd64 link (a `.deb`) and arm64 link (a Windows zip) are both wrong for a web container. Use the `html.zip` for both arches. |
| Checksum source | Upstream publishes `Verify.sha256` in the same release: `6f3d06891117072e62b43b08a84bdaf4fc43c0aae6127ac6c2e7564299d8a890 *KeeWeb-1.18.7.html.zip`. I downloaded the zip and its sha256 matches. |
| License file | Not inside the zip. Fetch `https://raw.githubusercontent.com/keeweb/keeweb/v1.18.7/LICENSE` for the same tag. |
| Ports / env / config | Upstream image listens on 80/443 (nginx, TLS certs in `/etc/nginx/external`). Our image uses the nginx base on 8080 and needs no env vars. `index.html` contains `<meta name="kw-config" content="(no-config)">`, so there is no server-side config. |
| Upstream Dockerfile reviewed | https://github.com/keeweb/keeweb/blob/v1.18.7/package/docker/Dockerfile (`FROM nginx:stable`, copies `dist` to `/keeweb`, bundles keeweb-plugins). The master branch Dockerfile (alpine-base, amd64 only) is a different build and is not used. |

## 2. Target layout

```
apps/keeweb/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
```

- No `start.sh`: the nginx base image already supplies `CMD ["nginx","-c","/config/nginx.conf",...]` and its `docker-entrypoint.d/03-copyconfig.sh` seeds `/config/nginx.conf` and `/config/sites/default.conf` (read from `apps/nginx`). The seeded `default.conf` already listens on 8080 with `root /usr/share/nginx/html`, which is exactly where KeeWeb goes.
- No `defaults/`, `docker-entrypoint.d/`, `etc/`, `health/`: nothing extra to seed. No `root/`. No `DOWNSTREAM_CHANGES.md` (nothing uses keeweb as a `FROM` base).
- Closest siblings: `apps/theme-park` and `apps/it-tools` (static files on the nginx base).

## 3. Base image

```
FROM ghcr.io/trueforge-org/nginx:1.28.3@sha256:1e4f20bfcf614853820179bb28127b1375061c09f565bb7010495845d4742c9f
```

Static web app served by nginx, as the draft proposes. Same base as `apps/theme-park`. No build stage is needed because the release zip is prebuilt.

## 4. Dockerfile

1. `FROM` as above, then `ARG VERSION`.
2. `USER root` (only for the install step).
3. One `RUN set -eux` step:
   - `cd /tmp`
   - `curl -fsSLO "https://github.com/keeweb/keeweb/releases/download/v${VERSION}/KeeWeb-${VERSION}.html.zip"`
   - `curl -fsSLo Verify.sha256 "https://github.com/keeweb/keeweb/releases/download/v${VERSION}/Verify.sha256"`
   - `grep " \*KeeWeb-${VERSION}.html.zip\$" Verify.sha256 | sha256sum -c -` (upstream checksum, fails the build on mismatch)
   - `rm -rf /usr/share/nginx/html/*` (drop the stock nginx welcome page)
   - `unzip -q "KeeWeb-${VERSION}.html.zip" -d /usr/share/nginx/html` (`unzip` is in the ubuntu base)
   - `mkdir -p /usr/share/licenses/keeweb && curl -fsSLo /usr/share/licenses/keeweb/LICENSE "https://raw.githubusercontent.com/keeweb/keeweb/v${VERSION}/LICENSE"`
   - `chown -R 568:568 /usr/share/nginx/html && find /usr/share/nginx/html -type d -exec chmod 755 {} + && find /usr/share/nginx/html -type f -exec chmod 644 {} +`
   - `rm -rf /tmp/*`
4. `COPY --chmod=0755 . /` (only `container-test.yaml` passes the `.dockerignore` allow-list here).
5. `EXPOSE 8080`, `VOLUME /config`.
6. Final `USER apps`.

No apt packages are installed, so there is nothing to pin. The `VERSION` ARG is the version of the files in the image.

## 5. docker-bake.hcl

- `APP` = `keeweb`
- `VERSION`:
  ```hcl
  // renovate: datasource=github-releases depName=keeweb/keeweb versioning=semver
  default = "1.18.7"
  ```
- `LICENSE` = `MIT`, `SOURCE` = `https://github.com/keeweb/keeweb`
- Targets `docker-metadata-action`, `image` (args `VERSION`, OCI source/licenses labels), `image-local` (`type=docker`, tag `${APP}:${VERSION}`), `image-all` (`linux/amd64`, `linux/arm64`), plus `group "default" { targets = ["image-local"] }`, copied from `apps/adguardhome-sync/docker-bake.hcl`.
- Validate with `cd apps/keeweb && docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/keeweb/keeweb"
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

No `dependencies:` entry (draft: none). `TZ` is listed like the other nginx-family apps. The upstream image's `PORT_HTTP`/`PORT_HTTPS` belong to the keeweb alpine-base build and are not read by our image, so they are not listed.

## 7. start.sh

Not applicable: the nginx base provides the CMD and the `docker-entrypoint.d` seeding. All writes already go to `/config` (seeded config) and `/tmp` (pid, temp and cache paths, set in the seeded `nginx.conf`).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

http:
- port: '8080'
  path: /
filePaths:
- /usr/share/nginx/html/index.html
- /usr/share/licenses/keeweb/LICENSE
```

One probe for the single declared port. `timeoutSeconds` is left at the default, as in `apps/it-tools` and `apps/theme-park`. No env vars are needed.

## 9. Rootless and read-only-rootfs adaptations

- Upstream writes: nginx pid, temp and cache dirs. The nginx base already remaps them to `/tmp` and keeps config in `/config`. KeeWeb itself writes nothing server-side. User settings and database files live in the browser (localStorage) or on remote storage (WebDAV, Dropbox and so on).
- Draft expectations: chart runs as UID 0 with a writable rootfs. Ours runs as UID 568 (`apps`), `readOnlyRootFilesystem: true`, not privileged.
- The chart's extra persistence `/etc/nginx/external` held TLS certificates and DH params for the upstream image's own HTTPS. We serve plain HTTP on 8080 and leave TLS to the ingress/reverse proxy, so that mount is dropped and `/config` is the only volume.

## 10. Risks, caveats and open questions

- KeeWeb relies on Web Crypto, which browsers only expose on HTTPS or `localhost` (general browser behaviour, not tested here). Reverse-proxy TLS is needed for any non-local use. Mention it in the PR.
- Latest stable is from 2021. Prereleases 1.18.8/1.18.9 exist; renovate will ignore them. Ask maintainers if they want to track the prerelease.
- Upstream's image bundles keeweb-plugins; we do not. UNVERIFIED how users would load plugins or a `config.json` through the `kw-config` meta without editing `index.html`; out of scope here.
- Draft caveat "chart pulls `:latest`" is solved by pinning `VERSION`.
- Blockers: none. The artifact is architecture independent, so arm64 works.

## 11. Build and test steps

```sh
cd apps/keeweb
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create keeweb-probe-config
docker run --rm -d --name keeweb-probe --read-only --tmpfs /tmp \
  -v keeweb-probe-config:/config keeweb:1.18.7
docker logs -f keeweb-probe     # expect the entrypoint to run 03-copyconfig.sh, nginx to stay up, no errors
curl -fsS http://<container-ip>:8080/ | head -c 200   # expect KeeWeb HTML
docker rm -f keeweb-probe; docker volume rm keeweb-probe-config
forgetool containers test --image keeweb:1.18.7 --config ./apps/keeweb/container-test.yaml
```

Readiness signal: `[entrypoint] Configuration complete`, the nginx process still running, and port 8080 answering with 200.

## 12. PR checklist

- Branch `feat/add-keeweb` from `main`; commit and PR title `feat(keeweb): add new container`.
- Fill in `.github/PULL_REQUEST_TEMPLATE.md`, keeping its sections; only check boxes that apply. Put `🤖 This PR is AI generated.` in the Notes section.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (the `license/cla` check shows status). Only the user can sign it.
- Pre-completion: bake `--print` OK, `VERSION` matches the Dockerfile ARG, runs as `apps` on a read-only rootfs with empty `/config`, test assertions unchanged.
- Untested by this plan (state honestly in the PR): the Dockerfile has not been built or run; arm64 is not built; the Web Crypto/HTTPS caveat is not checked in a browser; the `Verify.sha256` grep pattern is not yet run in a build.
