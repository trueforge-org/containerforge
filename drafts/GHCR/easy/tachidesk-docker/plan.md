# tachidesk-docker — implementation plan
> Source: ./draft.md · Target: apps/tachidesk-docker/ · Difficulty: easy · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | Latest stable release: `v2.4.2373` (published 2026-11-21T20:00:32Z). Draft pins `v2.4.2366` (published 2026-09-30T03:11:16Z). Plan pins `v2.4.2373`. Source: `gh api repos/Suwayomi/Suwayomi-Server/releases/latest`. Chart uses the moving tag `ghcr.io/suwayomi/tachidesk:preview` (upstream status, not used as a pin). |
| Renovate | `// renovate: datasource=github-releases depName=Suwayomi/Suwayomi-Server versioning=loose`. Tags are `v2.4.NNNN` (not strict semver), so `loose` per the bake rule. |
| License | MPL-2.0 (GitHub API `repos/Suwayomi/Suwayomi-Server`, `license.spdx_id`). |
| Source URL | https://github.com/Suwayomi/Suwayomi-Server |
| Download | Arch-neutral JAR: `https://github.com/Suwayomi/Suwayomi-Server/releases/download/v2.4.2373/Suwayomi-Server-v2.4.2373.jar`, sha256 `dd05d523cc785b7acf90c9feac0bc84c53d5fb3af5ab2a33653646e2076e5217` (GitHub asset digest). Also `Suwayomi-Server-v2.4.2373-linux-x64.tar.gz` (bundled runtime, sha256 `29de723470f2e89dc1f0730e7eeb69c6a048a83217b1b2fd8451441d267e2ec2`). Not used: the JAR runs on the java sibling. |
| Checksum source | Release asset `Checksums.sha256` (sha256 `60eee1b0d1c8c8c9286007c9f071af62e0429e1ca5a97f7f7acd20d5e513bd23`) and the GitHub asset digests above. |
| Upstream Dockerfile reviewed | `suwayomi/docker-tachidesk` @ `7a2bdee0b5aab381f80a9186ef8c73507771050f`: https://raw.githubusercontent.com/suwayomi/docker-tachidesk/7a2bdee0b5aab381f80a9186ef8c73507771050f/Dockerfile. Base `eclipse-temurin:25.0.5_8-jre-noble`; apt `curl gettext-base unzip tini ca-certificates p11-kit`; user `suwayomi` uid/gid 1000 with HOME `/home/suwayomi`; `WORKDIR /home/suwayomi`; `USER suwayomi`; `EXPOSE 4567`; `ENTRYPOINT ["tini", "--"]`; `CMD ["/home/suwayomi/startup_script.sh"]`; `ENV MALLOC_ARENA_MAX=2` and `JDK_JAVA_OPTIONS` (GC tuning); `VOLUME` none. The JAR is downloaded to `/home/suwayomi/startup/tachidesk_latest.jar`. Optional KCEF (Chromium) is controlled by `TACHIDESK_KCEF`. |
| Port | `4567` (`EXPOSE 4567`, confirmed in upstream Dockerfile). |
| Env vars (real) | Image: `HOME`, `MALLOC_ARENA_MAX`, `JDK_JAVA_OPTIONS` (confirmed). Server config variables and `startup_script.sh` contents: UNVERIFIED (script not fetched). |
| Data path | `/home/suwayomi/.local/share/Tachidesk` (chart paths from the draft; the upstream image chmods `/home/suwayomi` to 777). Downloads and local data under the same root (draft). |
| arm64 | JAR is arch-neutral: yes. Upstream Dockerfile handles both `linux/amd64` and `linux/arm64` (KCEF branch). Manifest for the `preview` tag: UNVERIFIED. |
| Dependencies | None (no external DB in the upstream Dockerfile). |
| Java version | Upstream runs on Temurin 25 (`25.0.5_8-jre-noble`). Draft says the java21 sibling. See section 3. |

## 2. Target layout

- `apps/tachidesk-docker/Dockerfile`
- `apps/tachidesk-docker/docker-bake.hcl`
- `apps/tachidesk-docker/settings.yaml`
- `apps/tachidesk-docker/container-test.yaml`
- `apps/tachidesk-docker/start.sh`

No `defaults/`, `etc/`, `health/` needed (Tachidesk creates its data on first start; confirm during the run). No `root/`. No `DOWNSTREAM_CHANGES.md` (not used as a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/java25:25.0.1@sha256:22a0f8a73c79e2f733c7513aefceef24ab8a213fd35af0ab1946996efc21636d` (sibling `apps/java25`, from the brief).

Why not java21 (the draft's choice): the upstream image is built on Temurin 25, so Java 25 matches the runtime Suwayomi is tested with. Java 21 is UNVERIFIED for this JAR. If the maintainer prefers java21 (`ghcr.io/trueforge-org/java21:21.0.8@sha256:bba631340c8aefc1a10656a894475312bd89a9dd75d9e5da12c3098242f1e8f2`, copied from an existing `FROM` in `apps/*/Dockerfile`), run the JAR on it first and record the result. Closest sibling for layout: `apps/java21` and `apps/java25` (Temurin, `USER apps`).

## 4. Dockerfile

1. `ARG VERSION` (`2.4.2373`, `v`-less or tag form matched to the bake), `ARG TARGETARCH` (unused for the JAR, kept only if needed).
2. `FROM ghcr.io/trueforge-org/java25:25.0.1@sha256:22a0f8...` (section 3).
3. `USER root`.
4. `mkdir -p /app/tachidesk` first (the download below writes into it), then download and verify the JAR:
   ```dockerfile
   RUN set -eux; \
       curl -fsSL -o /app/tachidesk/Suwayomi-Server.jar \
         "https://github.com/Suwayomi/Suwayomi-Server/releases/download/v${VERSION}/Suwayomi-Server-v${VERSION}.jar"; \
       curl -fsSL -o /tmp/Checksums.sha256 \
         "https://github.com/Suwayomi/Suwayomi-Server/releases/download/v${VERSION}/Checksums.sha256"; \
       grep 'Suwayomi-Server-v'"${VERSION}"'.jar$' /tmp/Checksums.sha256 | sha256sum -c -; \
       rm -f /tmp/Checksums.sha256
   ```
   Verify the checksum line format against the real `Checksums.sha256` first (the release file lists names; UNVERIFIED for the exact format).
5. License: `COPY` or `curl` of the repo `LICENSE` (MPL-2.0) to `/usr/share/licenses/tachidesk-docker/LICENSE` (the JAR alone is a third-party bundle: ship its notices too). Source for the text: the repo at tag `v2.4.2373` (UNVERIFIED: not fetched).
6. `chown -R apps:apps /app && chmod -R 755 /app` (sibling precedent: `apps/adguardhome-sync`).
7. `apt-get` is not needed (base has curl, tar, unzip; `tini` is not required: the ContainerForge base handles PID 1 through `start.sh`'s `exec`). Do not install `tini` unless the process model needs it.
8. `ENV HOME=/config` (data goes to `/config`, not `/home/suwayomi`) and `ENV MALLOC_ARENA_MAX=2` (matches upstream).
9. `USER apps`, then `COPY --chmod=0755 . /`.
10. `EXPOSE 4567`, `VOLUME /config`, `WORKDIR /app/tachidesk`.

Note the draft says "Dockerfile's JRE base is replaced by the sibling": correct.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "tachidesk-docker"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=Suwayomi/Suwayomi-Server versioning=loose
  default = "2.4.2373"
}

variable "LICENSE" {
  default = "MPL-2.0"
}

variable "SOURCE" {
  default = "https://github.com/Suwayomi/Suwayomi-Server"
}
```

Then `image`, `image-local` (`${APP}:${VERSION}`), `image-all` (`linux/amd64`, `linux/arm64`) and `group "default" { targets = ["image-local"] }`, copied from `apps/adguardhome-sync/docker-bake.hcl`. Validate with `docker buildx bake --print`. Keep the `VERSION` default and the Dockerfile `ARG VERSION` aligned (same value and form).

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/Suwayomi/Suwayomi-Server"
ports:
  - port: 4567
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

Only the port confirmed by the upstream Dockerfile is listed. Add env vars only after `start.sh` or the server reads them (the server's config variable names are UNVERIFIED; do not invent them). `JDK_JAVA_OPTIONS` is not listed: it is an upstream image tuning default, not an app setting.

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

# Data root: the server stores its state under HOME (/config)
export HOME=/config
mkdir -p /config/Tachidesk /tmp/tachidesk

cd /app/tachidesk
exec java ${JDK_JAVA_OPTIONS:-} -jar /app/tachidesk/Suwayomi-Server.jar
```

Notes:
- Idempotent: only creates directories; no seeding needed unless the server needs a config file (UNVERIFIED; check on the first empty-`/config` run and add a `cp -n` of a default file under `/defaults` only if required).
- No writes to `/app`. The WebUI and extension downloads go to the data directory under `/config`, not `/app` (confirm; if the server writes its WebUI to `/app`, redirect it to `/tmp` or `/config` via the server's own setting, UNVERIFIED).
- Bind address: the server must listen on all interfaces. The upstream default is UNVERIFIED (not confirmed); check in the run log, and add a bind-address setting only if the server defaults to localhost.
- `exec` gives the JVM PID 1 signal handling (the base has no tini; the JVM handles SIGTERM).
- Chart data paths (`/home/suwayomi/.local/share/Tachidesk`, `/downloads`, `/local`) are remapped to `/config` (section 9). The server's own data-dir variable is UNVERIFIED; if it exists, set it to `/config/Tachidesk` in `start.sh`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 300
tcp:
- port: '4567'
http:
- port: '4567'
  path: /
filePaths:
- /app/tachidesk/Suwayomi-Server.jar
- /usr/share/licenses/tachidesk-docker/LICENSE
- /start.sh
```

- `timeoutSeconds: 300`: the JVM and the first WebUI/extension fetch are slow. Sibling Java apps use a similar value (check `apps/java21`-family `container-test.yaml` before merging).
- The http probe path `/` is a guess until the first run shows the real response code; keep it only if it returns 200 (UNVERIFIED).
- No DB, so no narrowed assertions.
- The test runs without network-dependent env; if the first start needs internet to fetch the WebUI, the readiness probe may fail in CI. Record that in the PR rather than weakening the test.

## 9. Rootless and read-only-rootfs adaptations

| Upstream/chart write path | Remap |
| --- | --- |
| `/home/suwayomi/.local/share/Tachidesk` (data) | With `HOME=/config` the default data dir would be `/config/.local/share/Tachidesk` (XDG default under HOME), not `/config/Tachidesk`. UNVERIFIED; confirm the real path on the first run and make `start.sh`, the `mkdir` and the paths below agree. |
| `/home/suwayomi/.local/share/Tachidesk/downloads` (chart PVC) | `/config/Tachidesk/downloads` (same root; no separate mount needed) |
| `/home/suwayomi/.local/share/Tachidesk/local` (chart PVC) | `/config/Tachidesk/local` |
| `/home/suwayomi/startup/tachidesk_latest.jar` (upstream image) | `/app/tachidesk/Suwayomi-Server.jar` (baked in, read-only) |
| `/tmp` (JVM temp, native libs) | `/tmp` tmpfs at run time; `JAVA_TOOL_OPTIONS` not needed |
| KCEF / Chromium (upstream optional) | Not included: the java sibling does not ship Chromium. UNVERIFIED whether the server runs without it (upstream auto-detects by platform). |

Security expectations (draft, chart values): non-root (568 default; this plan runs `apps`), read-only rootfs not set by chart (this plan is read-only compatible), privileged no, extra PVCs for the three data paths (replaced by one `/config` volume).

## 10. Risks, caveats and open questions

- Version drift: the chart uses the moving `preview` tag. The plan pins `v2.4.2373`; the chart may change behaviour on pull. Record the pinned version in the PR.
- Java version: upstream uses Temurin 25; the draft's java21 choice is UNVERIFIED. The plan uses java25 (section 3).
- The upstream `startup_script.sh` and server config variable names are not fetched: UNVERIFIED. Do not write env vars in `settings.yaml` until the run confirms them.
- WebUI and extensions are downloaded at runtime from the internet (draft, inferred): first start is slow and needs network. The readiness signal may need a long window.
- The draft's "/config layout needs remapping" caveat is handled in section 9. Existing chart data at the three PVC paths must be copied to `/config/Tachidesk` by the user (data migration note for the PR).
- arm64: the JAR runs on any arch; the `preview` manifest is UNVERIFIED, but `image-all` lists both platforms. If arm64 fails, say so in the PR rather than dropping it silently.
- Blockers: none known beyond the UNVERIFIED items above.

## 11. Build and test steps

```sh
cd apps/tachidesk-docker
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name tachidesk-docker-probe --read-only --tmpfs /tmp \
  -v tachidesk-docker-probe-config:/config tachidesk-docker:2.4.2373
docker logs -f tachidesk-docker-probe
forgetool containers test --image tachidesk-docker:2.4.2373 --config ./apps/tachidesk-docker/container-test.yaml
docker rm -f tachidesk-docker-probe; docker volume rm tachidesk-docker-probe-config
```

- Expected readiness signal: Ktor/Javalin-style "listening" line or the server's startup banner (UNVERIFIED text; take the real line from the first log). The container must stay running with no fatal exception.
- Use a fresh `/config` volume per round (empty-`/config` start).
- Network: the first start needs the internet for WebUI/extensions; record the result if the CI runner has no network.

## 12. PR checklist

- Branch `feat/add-tachidesk-docker`, commit `feat(tachidesk-docker): add new container`, PR title the same.
- Use `.github/PULL_REQUEST_TEMPLATE.md`; keep sections and checkboxes; only check what applies.
- Notes section: `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign it; the `license/cla` check shows the status).
- Say what was not tested: arm64 (manifest unverified), the WebUI download path if there is no network, the java21 alternative, and the data migration from the chart PVCs.
- Confirm `docker buildx bake --print` ran and whether the image built.
