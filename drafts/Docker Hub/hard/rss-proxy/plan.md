# rss-proxy — implementation plan
> Source: ./draft.md · Target: apps/rss-proxy/ · Difficulty: hard (no release assets, binary only inside an upstream image, amd64-only tags) · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | 2.1.1 (Docker Hub tags `2`, `2.1`, `2.1.1`, `2.1.0`, updated 2023-06-06, amd64). The `2.1-arm` tag (arm64, 2023-05-27) has no patch-level tag. `latest` is from 2021-01-16 and is v1, so the draft's `latest` is old and misleading. |
| Draft tag | `docker.io/damoeb/rss-proxy:latest`. Replaced by the pinned `2.1.1`. |
| Renovate | `datasource=docker depName=damoeb/rss-proxy versioning=semver` (only for the `COPY --from` source tag). The GitHub repo has no releases, so `github-releases` does not work. |
| License | GPL-3.0 (README says GNU GPLv3). SPDX `GPL-3.0-only`. UNVERIFIED: `-only` or `-or-later`; and the bundled feedless core jar may carry another license. |
| Source | https://github.com/damoeb/rss-proxy |
| Status | The README calls rss-proxy "an alternative UI to feedless with a reduced feature set" and feedless "the successor of rss-proxy". The last image push was 2023, so the project is likely in maintenance only. |
| Download URLs | None: "Releases" is empty. The artifact exists only inside the `damoeb/rss-proxy:2.1.1` image. |
| Checksum | Not applicable. Pin the source image by digest: `damoeb/rss-proxy:2.1.1@sha256:<digest>`; get it with `docker buildx imagetools inspect damoeb/rss-proxy:2.1.1`. UNVERIFIED: the digest. |
| Upstream Dockerfile reviewed | https://github.com/damoeb/rss-proxy/blob/d91dbde/Dockerfile (summarised by the fetch tool, not verbatim): `FROM damoeb/feedless:core-0.1.3`; ENV `APP_AUTHENTICATION=authRoot`, a JWT secret, `APP_HOST_URL=http://localhost:8080`, root email `admin@localhost`, root secret key, actuator password (placeholders are all `password`), `TZ` Europe/Berlin, log level error, active profiles `legacy,cache,static`, `APP_WHITELISTED_HOSTS` empty, anonymous tokens valid 3 days; copies `packages/playground/dist/` into `./public`. |
| Ports | 8080/tcp (README, `docker run -p 8080:8080`). Legacy v1 used 3000 and is not used. |
| Env vars | `APP_API_GATEWAY_URL` (README: outward-facing URL used as host in generated feeds). Others from the Dockerfile summary: `APP_AUTHENTICATION`, `APP_HOST_URL`, `APP_WHITELISTED_HOSTS`. UNVERIFIED: exact names of the JWT, root email, root secret and actuator password variables, and the profile variable (probably `SPRING_PROFILES_ACTIVE`). |

## 2. Target layout

- `apps/rss-proxy/Dockerfile`
- `apps/rss-proxy/docker-bake.hcl`
- `apps/rss-proxy/settings.yaml`
- `apps/rss-proxy/container-test.yaml`
- `apps/rss-proxy/start.sh`

No `defaults/` unless the feedless core needs a config file (UNVERIFIED). No `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/java17:17.0.16@sha256:74b81362a2cf4b7f6efb8eb67baf0d1090ce56b38fc9e7a0dc11333b35179e1a`

The core is a JVM app (Spring-style `APP_*` properties). UNVERIFIED: the Java version of `feedless:core-0.1.3`; if it needs 21 or 25, switch to `java21` (`apps/java21` exists; copy the FROM line from an existing apps/*/Dockerfile that uses it). The draft alternative `python-node` is not needed: the Node part is only the prebuilt static `public/` UI. Closest sibling: `apps/nzbhydra2` (jar on java17, `--datafolder /config`).

## 4. Dockerfile

1. `ARG VERSION` (2.1.1), `USER root`.
2. Source stage, because there is no release asset:
   ```dockerfile
   FROM docker.io/damoeb/rss-proxy:2.1.1@sha256:<digest> AS source
   ```
   (a `# renovate: datasource=docker depName=damoeb/rss-proxy` comment goes above the line.) The tag cannot use `ARG VERSION` in the digest form, so keep the literal tag and keep it identical to `VERSION` in `docker-bake.hcl`.
3. Final stage copies the artifacts. Paths are UNVERIFIED and must be found first with `docker run --rm --entrypoint sh damoeb/rss-proxy:2.1.1 -c 'ls -la / /app /opt 2>/dev/null; ps'` or `docker image inspect`; expected: an executable jar (or exploded `BOOT-INF`) plus `/public` (static UI) and the entrypoint. Copy with `COPY --from=source --chown=568:568 <jar> /app/rss-proxy.jar` and `COPY --from=source <public> /app/public`.
4. Verify the copied jar is glibc-compatible (a pure jar on a JRE is). If the source image bundled a JRE on Alpine, do not copy the JRE: java17 from the base is used.
5. Licenses: `mkdir -p /usr/share/licenses/rss-proxy`, copy the source repo's LICENSE (not in the image; fetch `https://raw.githubusercontent.com/damoeb/rss-proxy/<tag-or-commit>/LICENSE` at build with a pinned commit, UNVERIFIED path).
6. `chown -R apps:apps /app && chmod -R 755 /app`.
7. `ENV TZ=Etc/UTC HOME=/config JAVA_TOOL_OPTIONS="-Xmx256M"` (sibling pattern) and `SPRING_TMP`-style temp dir `-Djava.io.tmpdir=/tmp` (UNVERIFIED that the app is Spring; harmless).
8. `USER apps`, then `COPY --chmod=0755 . /`.
9. `EXPOSE 8080`, `VOLUME /config`, `WORKDIR /config`.

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "rss-proxy" }
variable "VERSION" {
  // renovate: datasource=docker depName=damoeb/rss-proxy versioning=semver
  default = "2.1.1"
}
variable "LICENSE" { default = "GPL-3.0-only" }
variable "SOURCE" { default = "https://github.com/damoeb/rss-proxy" }
```
Targets: `docker-metadata-action`, `image`, `image-local`, `image-all` (`linux/amd64`, `linux/arm64`; see the arm64 risk in section 10), `group "default"`. The `image` target passes `VERSION` as arg. Validate with `docker buildx bake --print`.

## 6. settings.yaml

- Schema header, `schema_version: 1`, `upstream_env_url: "https://github.com/damoeb/rss-proxy"`.
- `ports`: `8080` tcp, required false.
- `env`: `APP_API_GATEWAY_URL` default `http://localhost:8080`, required false (verified name; the README example value is a placeholder); `APP_HOST_URL` default `http://localhost:8080` (from the upstream Dockerfile summary), required false; `TZ` default `Etc/UTC`, required false. Do not list the JWT and root-secret variables until their names are confirmed.
- `volumes`: `/config` required true (only if the app persists anything; UNVERIFIED, the v2 rss-proxy README says "persistence" is feedless-only, so it may be stateless. Keep `/config` as the working directory anyway).
- `dependencies:` none.

## 7. start.sh

- `set -eu`. Secrets: the upstream image ships the literal secret `password` for the JWT, root and actuator values. On start, generate random values into `/config/secrets.env` only when missing (`openssl rand -hex 32`), then export them from the file. Names are UNVERIFIED; fill them from the feedless core's configuration docs before implementing.
- Defaults only when unset: `export APP_API_GATEWAY_URL="${APP_API_GATEWAY_URL:-http://localhost:8080}"`.
- Bind to all interfaces: set `SERVER_ADDRESS=0.0.0.0` only if the app is Spring Boot and does not already (UNVERIFIED, test with an external probe).
- Final command (jar path from step 3 of section 4): `exec java -Djava.io.tmpdir=/tmp -jar /app/rss-proxy.jar "$@"`. No writes to `/app`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 180
http:
- port: '8080'
  path: /
filePaths:
- /app/rss-proxy.jar
```
JVM apps are slow to start, so 180 is chosen as a generous value (UNVERIFIED against sibling timeouts; compare `apps/nzbhydra2/container-test.yaml` when porting). The generated-secrets branch runs even without env vars, so it is covered by the test.

## 9. Rootless and read-only-rootfs adaptations

- Draft expects root and a writable rootfs. Reconciled: user `apps` 568, read-only rootfs, `/config` volume, `/tmp` for the JVM temp dir and caches.
- Write paths: JVM temp (`/tmp`), the app's log file (if any, UNVERIFIED path; redirect to console or `/tmp`), generated secrets file (`/config/secrets.env`), possible H2/SQLite/cache directory (UNVERIFIED; check the Spring `legacy,cache,static` profiles, probably in-memory).
- `public/` is read-only static content in `/app/public`.
- Headless-browser prerendering ("JavaScript prerendering") is feedless-only per the README, so no Chromium is installed.

## 10. Risks, caveats and open questions

- Blocker-level: no release assets and no public build recipe for the core jar. The plan depends on `COPY --from` a Docker Hub image the project last pushed in 2023. If the user wants a source build, that means building feedless (JVM + Node) and is a much larger task.
- arm64: only a separate `2.1-arm` tag exists, so a single multi-arch `COPY --from` cannot pick it; the copied jar is architecture independent, so amd64 source is usable for both targets (UNVERIFIED that no native libraries are inside).
- Draft says "headless browser rendering" and "node runtime": not part of rss-proxy 2.x per the README. The draft's confidence was low.
- Upstream default secrets are `password`: the plan replaces them at start. Names of those variables are UNVERIFIED.
- Possible upstream deprecation in favour of feedless: ask the user whether `feedless` should be ported instead.

## 11. Build and test steps

Follow `.github/instructions/build-test-protocol.instructions.md` for `apps/rss-proxy`, one app at a time, 10 rounds at most.

```sh
cd apps/rss-proxy
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create rss-proxy-probe-config
docker run --rm -d --name rss-proxy-probe --read-only --tmpfs /tmp \
  -v rss-proxy-probe-config:/config rss-proxy:2.1.1
docker logs -f rss-proxy-probe
forgetool containers test --image rss-proxy:2.1.1 --config ./apps/rss-proxy/container-test.yaml
docker rm -f rss-proxy-probe; docker volume rm rss-proxy-probe-config
```

- Expected readiness signal: Spring/Java startup log with a "Started ... in ... seconds" style line (UNVERIFIED wording) and HTTP 200 on port 8080.
- Always start with an empty `/config` volume (fresh volume each round).
- By-hand checks outside the test: confirm the generated secrets file exists in /config and is not the literal "password"; open the UI and generate a feed from a public URL.
- Only try arm64 if an amd64 build is green and a failure is arm64-specific.

## 12. PR checklist

- Branch `feat/add-rss-proxy` from a freshly pulled `main`; commit and PR title `feat(rss-proxy): add new container`.
- Fill in `.github/PULL_REQUEST_TEMPLATE.md` keeping its sections; check only the boxes that apply. Put `🤖 This PR is AI generated.` in the Notes section.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (the `license/cla` check shows the status). Only the user can sign it.
- Confirm: changes only in `apps/rss-proxy/`; `ARG VERSION` matches `docker-bake.hcl`; `docker buildx bake --print` passes; final `USER apps`; `COPY --chmod=0755 . /` present; runs read-only with empty `/config`; no assertion weakened.
- Not tested, to state honestly in the PR unless done: arm64, the copied jar paths and Java version, every secret variable name, generated feeds.
