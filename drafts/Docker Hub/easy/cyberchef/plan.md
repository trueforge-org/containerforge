# cyberchef — implementation plan
> Source: ./draft.md · Target: apps/cyberchef/ · Difficulty: easy · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | `v11.6.0` is the latest tag and release (2026-11-20 build date inside the zip). The draft and the chart use `v11.5.0` (via `mpepping/cyberchef:v11.5.0`), which is one release behind. Use `v11.6.0`. |
| Tag format | `vX.Y.Z` (with `v`), like `apps/it-tools` |
| Renovate | `datasource=github-releases depName=gchq/CyberChef` (default semver; the `v` prefix is kept) |
| License | `Apache-2.0` (repo `LICENSE` is the Apache License 2.0) |
| Source (`SOURCE`, `upstream_env_url`) | https://github.com/gchq/CyberChef |
| Download (both arch) | Architecture independent static bundle. Release asset name contains the tagged commit: `CyberChef_<40-char commit sha>.zip`. For `v11.6.0` it is `CyberChef_f464d62c7c943cda9749a765932a7548ba9bfb16.zip` (HTTP 200); for `v11.5.0` it is `CyberChef_8cd426dd4f40f1423912d5fad91b578a86a65112.zip` (the draft link). The commit equals the peeled tag: `git ls-remote https://github.com/gchq/CyberChef "refs/tags/v11.6.0^{}"` prints `f464d62c...`, so the name can be derived at build time. There is no `CyberChef_v11.6.0.zip` asset (404). |
| Zip content (inspected) | Flat layout: `CyberChef_v11.6.0.html`, `index.html.gz`, `index.html.br`, `assets/`, `images/`, `modules/`, `*Worker.js.LICENSE.txt`. There is NO plain `index.html`. `zcat index.html.gz` is byte-identical to `CyberChef_v11.6.0.html`, so the page must be copied to `index.html`. |
| Checksum source | No checksum file. GitHub shows the asset digest on the release (`expanded_assets/v11.6.0` page contains exactly one `sha256:` value: `6b6518c620d43776c19bf5cea1fd4a505b018bc829f7e88f7f77be38d64598d9`, which matched the downloaded zip when hashed locally). Use that page as the checksum source. |
| Upstream Dockerfile reviewed | https://github.com/mpepping/docker-cyberchef/blob/master/Dockerfile (draft's link): builds from source with node and serves `build/prod` on port 8000 from `nginxinc/nginx-unprivileged`. We do not copy this; we use the release zip as the draft says. |
| Ports | 8080/tcp from our nginx base (upstream image uses 8000; the draft says 80). Static files only. |
| Env vars / config | None. CyberChef runs fully in the browser. |
| Runtime | Pure static files, no server side processing. |

## 2. Target layout

```
apps/cyberchef/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
```

- No `start.sh`: the nginx base image already runs `nginx -c /config/nginx.conf -g "daemon off;"` as its `CMD`, and its `docker-entrypoint.d/03-copyconfig.sh` seeds `/config/nginx.conf` and `/config/sites/default.conf` with `cp -n` on an empty `/config`. The base `default.conf` already has `listen 8080`, `root /usr/share/nginx/html` and `index index.html index.htm`, which is all a static bundle needs. `apps/theme-park` ships no `start.sh` or `defaults/` for the same reason.
- No `defaults/`, `etc/`, `scripts/`, `health/` (nothing to seed). No `root/`. No `DOWNSTREAM_CHANGES.md`.
- If the first run shows the base default config is not enough, add `defaults/default.conf` plus `docker-entrypoint.d/10-copyconfig.sh` exactly like `apps/it-tools` (both paths are allowed by `include/.dockerignore`).

## 3. Base image

```
FROM ghcr.io/trueforge-org/nginx:1.28.3@sha256:1e4f20bfcf614853820179bb28127b1375061c09f565bb7010495845d4742c9f
```

Matches the draft ("Runtime image: nginx"). It already runs as `apps`, listens on 8080 and uses `/tmp` for temp and cache paths (rootless and read-only friendly). It descends from the ubuntu base, so `curl`, `git`, `unzip` and `ca-certificates` are present and need no `apt-get install` (the draft's inferred `unzip` is already there). Closest siblings: `apps/it-tools`, `apps/theme-park`.

## 4. Dockerfile

1. `FROM` as in section 3; `ARG VERSION`.
2. `USER root` for the install step only.
3. One `RUN set -eux` (everything under `/tmp`, no cache left behind):
   - `commit="$(git ls-remote https://github.com/gchq/CyberChef "refs/tags/${VERSION}^{}" | cut -f1)"` and fail if empty.
   - `curl -fsSLo /tmp/cyberchef.zip "https://github.com/gchq/CyberChef/releases/download/${VERSION}/CyberChef_${commit}.zip"`.
   - checksum: `expected="$(curl -fsSL "https://github.com/gchq/CyberChef/releases/expanded_assets/${VERSION}" | grep -o -E 'sha256:[0-9a-f]{64}' | head -n1 | cut -d: -f2)"`, fail if empty, then `echo "${expected}  /tmp/cyberchef.zip" | sha256sum -c -`. This page lists only the one asset digest (checked for v11.6.0); if GitHub changes the markup the build fails closed.
   - `rm -rf /usr/share/nginx/html/* && unzip -q /tmp/cyberchef.zip -d /usr/share/nginx/html`
   - `cp "/usr/share/nginx/html/CyberChef_${VERSION}.html" /usr/share/nginx/html/index.html` (the zip has no `index.html`, see section 1).
   - `chown -R 568:568 /usr/share/nginx/html` (the same numeric ownership `apps/it-tools` uses), `find ... -type d -exec chmod 755`, files `644`.
   - licence: `mkdir -p /usr/share/licenses/cyberchef && curl -fsSLo /usr/share/licenses/cyberchef/LICENSE "https://raw.githubusercontent.com/gchq/CyberChef/${VERSION}/LICENSE"`. The zip's `*.LICENSE.txt` third-party notices stay in the web root.
   - `rm -f /tmp/cyberchef.zip`
4. `COPY --chmod=0755 . /` (nothing from the app folder besides allow-listed files is copied; it is still required by the repo rules).
5. `EXPOSE 8080` (inherited from the base; restated for clarity), `VOLUME /config` (the base keeps its nginx config there).
6. Final `USER apps`. Do not override `CMD`/`ENTRYPOINT`: the base's `CMD ["nginx","-c","/config/nginx.conf","-g","daemon off;"]` is used.

Nothing is installed with apt, so nothing to pin. The web root contains exactly the `VERSION` release. The content is served from `/usr/share/nginx/html`, not `/app` (same as `apps/it-tools`, where nginx expects it); `/app` stays empty.

## 5. docker-bake.hcl

- `APP` = `cyberchef`
- `VERSION`:
  ```hcl
  // renovate: datasource=github-releases depName=gchq/CyberChef
  default = "v11.6.0"
  ```
- `LICENSE` = `Apache-2.0`
- `SOURCE` = `https://github.com/gchq/CyberChef`
- Standard targets as `apps/it-tools/docker-bake.hcl`: `docker-metadata-action`, `image` (args `VERSION`, OCI labels `source` and `licenses`), `image-local` (`type=docker`, tag `${APP}:${VERSION}`), `image-all` (`linux/amd64`, `linux/arm64`), `group "default"`.
- Validate: `cd apps/cyberchef && docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/gchq/CyberChef"
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

CyberChef reads no env vars. `TZ` is kept as in `apps/it-tools`. `NGINX_PORT` (listed in `apps/nginx/settings.yaml`) is not added: whether the base honours it for the port is UNVERIFIED here and CyberChef does not need it. Dependencies: none (static site; `nginx` is the base image, `apps/nginx` exists ✅).

## 7. start.sh

Not applicable: no `start.sh` is created. The nginx base starts the server through its `CMD` and the ubuntu entrypoint's `docker-entrypoint.d` hooks (empty `/config` is seeded by the base with `cp -n`, idempotent, nothing written to `/app`, temp paths already in `/tmp`, server bound to all interfaces on 8080). If section 2's fallback is needed, the `10-copyconfig.sh` hook only writes into `/config/sites`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

tcp:
- port: '8080'
http:
- port: '8080'
  path: /
  statusCode: 200
filePaths:
- /usr/share/nginx/html/index.html
- /usr/share/licenses/cyberchef/LICENSE
```

Covers the single port. The test runs with no env vars, which is fine because none exist. `timeoutSeconds` is omitted (nginx starts instantly, like `apps/it-tools`); set 60 only if the first run is flaky. Optionally add a content check that `/` returns the CyberChef page (`healthCommands` with `curl -s http://localhost:8080/ | grep -q CyberChef`; UNVERIFIED that curl output fits the schema's matching fields, so keep it optional).

## 9. Rootless and read-only-rootfs adaptations

| Write path | Handling |
|---|---|
| `/config/nginx.conf`, `/config/sites/*.conf` | seeded by the base on first start (`cp -n`), `/config` volume |
| nginx pid, proxy/client/fastcgi temp, cache | `/tmp/...` already set in the base's `nginx.conf` |
| `/usr/share/nginx/html` | read-only at runtime, only read |
| `/var/log/nginx/*.log` | symlinked to stdout/stderr by the base |

Draft expectations: chart runs as root on port 80 with a writable rootfs. We run as UID 568, `readOnlyRootFilesystem: true`, not privileged, port 8080 (a non-privileged port; chart service mapping must target 8080 instead of 80). No extra persistence is needed (draft: none).

## 10. Risks, caveats and open questions

- Draft pins `v11.5.0`; latest is `v11.6.0`. The plan uses the newer release.
- The release asset name contains the tag's commit sha, so a fixed URL cannot be derived from `VERSION` alone; the plan resolves it with `git ls-remote` (needs network and git during build, both available).
- The zip has no `index.html`; the build must copy the versioned HTML (verified identical to `index.html.gz` content).
- Checksum verification scrapes the GitHub release page; it fails closed if the format changes.
- The base nginx image tag `1.28.3` and digest come from the brief; if `apps/nginx/Dockerfile` has moved on, copy the newest FROM line from `apps/it-tools/Dockerfile`.
- UNVERIFIED until run: that the base's default `default.conf` serves `/` correctly with `index.html` plus the large `modules/` assets (mime types come from the base's `/etc/nginx/mime.types` include) and that web workers load (`.js` mime type).
- Updates need an image rebuild (no self-update); CyberChef never processes data on the server.
- No blockers: no musl, GPU, privileged mode or arch limitation.

## 11. Build and test steps

```sh
cd apps/cyberchef
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create cyberchef-probe-config
docker run --rm -d --name cyberchef-probe --read-only --tmpfs /tmp \
  -v cyberchef-probe-config:/config cyberchef:v11.6.0
docker logs -f cyberchef-probe     # expect "[entrypoint] Configuration complete" and no nginx [emerg]/[crit] lines
curl -sI http://$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' cyberchef-probe):8080/   # expect 200
docker rm -f cyberchef-probe; docker volume rm cyberchef-probe-config
forgetool containers test --image cyberchef:v11.6.0 --config ./apps/cyberchef/container-test.yaml
```

Also open the page in a browser or `curl` a deep asset, e.g. `/assets/fonts/Roboto72White.fnt`, to confirm static assets are served. Try arm64 only if amd64 passes and a problem is suspected (the bundle itself is arch independent).

## 12. PR checklist

- Branch `feat/add-cyberchef`, commit and PR title `feat(cyberchef): add new container`, target `main`.
- Use `.github/PULL_REQUEST_TEMPLATE.md`, only check boxes that apply.
- Put `🤖 This PR is AI generated.` in the Notes section.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign; `license/cla` shows status).
- Untested to state: arm64 build and run, behaviour inside the TrueCharts chart (port 80 to 8080 change), full browser use of all CyberChef operations.
- `docker buildx bake --print` before commit; changes only under `apps/cyberchef/`.
