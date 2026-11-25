# promcord — implementation plan
> Source: ./draft.md · Target: apps/promcord/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | No GitHub releases or tags (API 404, https://api.github.com/repos/nimarion/promcord/releases/latest). Last push 2023-03-06. Pin a master commit SHA as VERSION. Commit SHA is UNVERIFIED until chosen at build time. |
| Docker Hub image | `biospheere/promcord:latest` is amd64 only, last pushed 2021-11-01 (https://hub.docker.com/v2/repositories/biospheere/promcord/tags). Not used. |
| Renovate | `datasource=git-refs depName=https://github.com/nimarion/promcord currentValue=master` (same pattern as `apps/tvheadend`, see fenrus plan). |
| License | MIT (GitHub SPDX `MIT`, https://api.github.com/repos/nimarion/promcord). |
| Source URL | https://github.com/nimarion/promcord |
| Download | Source archive `https://github.com/nimarion/promcord/archive/${VERSION}.tar.gz`. No prebuilt binary. |
| Checksum source | None published. The archive is pinned by commit SHA. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/nimarion/promcord/master/Dockerfile: build stage `maven:3.8.1-adoptopenjdk-16`, runtime `openjdk:16-jdk-slim`, copies `target/promcord-*-SNAPSHOT-shaded.jar` to `promcord.jar`, `ENTRYPOINT ["java", "-jar", "promcord.jar"]`. No ENV, EXPOSE, VOLUME or USER. |
| Config | Env var `DISCORD_TOKEN` (README, https://raw.githubusercontent.com/nimarion/promcord/master/README.md). README says put it in `.env` for Docker installs. No config file path for the bot itself. |
| Ports | Not stated for the bot. README documents Prometheus `9090` and Grafana `80`/`3000` for the compose stack only. Bot metrics port and path: UNVERIFIED (not in README; source not read). |
| Data/config write paths | None documented. UNVERIFIED whether the jar writes anything. |
| Java version | Upstream builds and runs on Java 16. README does not state a version. The pom's `release`/`source` value: UNVERIFIED (pom not fetched). |
| arm64 | No prebuilt arm64 image. The jar is platform independent, so arm64 is covered by the source build (inference). |
| Dependencies | Discord bot application and token. No database. |

## 2. Target layout

- `apps/promcord/Dockerfile`
- `apps/promcord/docker-bake.hcl`
- `apps/promcord/settings.yaml`
- `apps/promcord/container-test.yaml`
- `apps/promcord/start.sh` (`exec java -jar /app/promcord/promcord.jar`, plus the token check decided in section 10)

No `defaults/`, `etc/`, `health/` needed. No `root/`. No `DOWNSTREAM_CHANGES.md` (not a FROM base).

## 3. Base image

- Build stage: `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`. The java17 image is a JRE only, so it cannot run Maven. Install a JDK and Maven from apt in this stage.
- Final stage: `FROM ghcr.io/trueforge-org/java17:17.0.16@sha256:74b81362a2cf4b7f6efb8eb67baf0d1090ce56b38fc9e7a0dc11333b35179e1a`. Nearest supported runtime to upstream Java 16.
- Alternative: `ghcr.io/trueforge-org/java21` (bake VERSION `21.0.8+9`; image tag form UNVERIFIED) is not the nearest runtime. Use java17 unless the pom requires 21.
- Closest siblings: `apps/java17`, `apps/nzbhydra2` (Java app on java base, `/config` volume). `apps/java21` exists as the alternative.

## 4. Dockerfile

1. `ARG VERSION` (commit SHA, matches `docker-bake.hcl`), `ARG TARGETARCH` not needed (jar is arch independent), `USER root` for the build stage.
2. Build stage: `apt-get install -y --no-install-recommends openjdk-17-jdk-headless maven` (package names and versions UNVERIFIED for ubuntu 26.04; confirm with `apt-cache policy` at build time). Not pinned against VERSION: these are toolchain packages, not the app.
3. `ENV MAVEN_OPTS=-Dmaven.repo.local=/tmp/m2` so the Maven cache stays in `/tmp`, not `/config` or `/app`.
4. `curl -fL https://github.com/nimarion/promcord/archive/${VERSION}.tar.gz | tar xz -C /tmp/src --strip-components=1`.
5. `cd /tmp/src && mvn -B -DskipTests package`. Output: `target/promcord-*-SNAPSHOT-shaded.jar`.
6. Final stage: `FROM <java17>`, `USER root`, `mkdir -p /app/promcord`, `COPY --from=build /tmp/src/target/promcord-*-SNAPSHOT-shaded.jar /app/promcord/promcord.jar`. Add the upstream license file to `/usr/share/licenses/promcord/`.
7. `USER apps`, `COPY --chmod=0755 . /`, `COPY --chmod=0755 start.sh /start.sh`.
8. No `EXPOSE` unless the metrics port is verified (section 10). End the file with `VOLUME /config` (repo rule), also declared in settings.yaml.

## 5. docker-bake.hcl

- `variable "APP" { default = "promcord" }`
- `variable "VERSION"` with `// renovate: datasource=git-refs depName=https://github.com/nimarion/promcord currentValue=master` and the chosen commit SHA as default.
- `variable "LICENSE" { default = "MIT" }`
- `variable "SOURCE" { default = "https://github.com/nimarion/promcord" }`
- Standard targets: `docker-metadata-action`, `image` (args `VERSION`, OCI labels source and licenses), `image-local` (`output = ["type=docker"]`, tag `${APP}:${VERSION}`), `image-all` (amd64, arm64), `group "default" { targets = ["image-local"] }`.
- Validate: `cd apps/promcord && docker buildx bake --print`.

## 6. settings.yaml

- Header: the `yaml-language-server` schema line and `schema_version: 1`, as in `apps/java17/settings.yaml`.
- `upstream_env_url: "https://github.com/nimarion/promcord"`
- `ports`: empty until the metrics port is verified (section 10). Do not list 8080 or any guess.
- `env`:
  - `DISCORD_TOKEN`, `required: false`, empty default: the image must start without env vars (container tests set none), and a real token can never be a default. Whether the app tolerates an empty token is UNVERIFIED (section 10).
  - `TZ`, default `Etc/UTC`, `required: false` (sibling convention).
- `volumes`: `/config`, `required: true`. Only if the jar writes state there (UNVERIFIED). Otherwise declare it anyway for sibling consistency and note it.
- `dependencies`: none.

## 7. start.sh

- `#!/usr/bin/env bash`, `set -eu`.
- Do not write to `/app`. Keep Java temp files in `/tmp` (`-Djava.io.tmpdir=/tmp`).
- Read `DISCORD_TOKEN` from the environment. Do not print it, and do not write it to a file.
- If the token decision is "fail fast", exit with a clear message when it is empty.
- Final line: `exec java -Djava.io.tmpdir=/tmp -jar /app/promcord/promcord.jar`. `exec` so signals reach the JVM.
- No seeding of `/config` unless the jar writes state there (UNVERIFIED).

## 8. container-test.yaml

- Header: the forgetool schema line, as in `apps/nzbhydra2/container-test.yaml`.
- No `tcp` or `http` probes until the metrics port is verified (every port in settings.yaml needs a probe).
- `filePaths`: `/app/promcord/promcord.jar` (exists). Add a token-path file only if the token check is in start.sh.
- `timeoutSeconds`: take from the java sibling (`apps/java17` or `apps/nzbhydra2`).
- Test runs without env vars, so the bot will not connect to Discord. This is the reason the readiness signal is not testable here; see section 10.

## 9. Rootless and read-only-rootfs adaptations

- Upstream runs as root with no USER. ContainerForge runs as `apps`, so the jar must be read-only from `/app/promcord`.
- The JVM needs `/tmp` for temp files and `/tmp` for Maven cache during build only.
- No writes to `/config` are known from the README. If the jar writes logs or cache, point them at `/tmp` or `/config` (decision pending UNVERIFIED).
- Upstream `.env` file lives in the project directory. In the image, the env var comes from settings.yaml and the orchestrator. No `.env` file is needed.
- Bind address: the bot does not listen on a port (Discord gateway client). The Prometheus endpoint must bind 0.0.0.0 if it exists (UNVERIFIED).

## 10. Risks, caveats and open questions

- **Token blocker (decision needed).** The bot needs `DISCORD_TOKEN` from the Discord developer portal, and the bot must be invited to a server. Without the token the test run has no readiness signal. Options: (a) `start.sh` fails fast with a clear message and the test asserts the process exits with that message (needs forgetool support, UNVERIFIED); (b) the jar starts and idles without a token (UNVERIFIED, must be tested locally). Do not weaken the test. Pick after a local run.
- **Java 16 to 17.** Upstream runs on openjdk 16. Behaviour on 17 must be checked with a real token, not just a start.
- **Metrics port unknown.** The draft's `8080/http` is an inference. Read `src/` for the port and path before listing it. Until then no port is declared.
- **No release tags.** Renovate tracks master. Pin the commit SHA and review each bump.
- **Upstream last pushed 2023-03-06.** Maintenance risk; the Docker Hub image is from 2021.
- **Downloaded tarball is not checksummed.** Commit SHA pinning is the only integrity check.
- **arm64 untested.** Source build should work on arm64, but it is not built locally.

Blockers that would stop the port: none found in the facts, provided the token behaviour in the first bullet is acceptable.

## 11. Build and test steps

Per `.github/instructions/build-test-protocol.instructions.md`, one app at a time, with `<app>` = promcord:

1. `cd apps/promcord && docker buildx bake --print` (must exit 0).
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`.
3. `docker run --rm -d --name promcord-probe --read-only --tmpfs /tmp -v promcord-probe-config:/config promcord:<version>`, then `docker logs -f promcord-probe`. Expected readiness signal: to be defined after the token decision (for example a Discord "logged in as" line, UNVERIFIED). Cleanup: `docker rm -f promcord-probe; docker volume rm promcord-probe-config`.
4. `forgetool containers test --image promcord:<version> --config ./apps/promcord/container-test.yaml`. If forgetool is unavailable, check the file assertions by hand.
5. arm64 only if amd64 fails for an arm64-specific reason.

## 12. PR checklist

- Branch `feat/add-promcord`, commit `feat(promcord): add new container`, PR title the same, targeting `main`.
- PR template `.github/PULL_REQUEST_TEMPLATE.md`, sections and checkboxes kept, only applicable boxes checked.
- Notes section includes `🤖 This PR is AI generated.`
- CLA: the user must sign at https://cla-assistant.io/trueforge-org/containerforge. Only the user can sign it. Tell the user.
- Say in the PR what was not tested: the Discord connection (no token), metrics endpoint (if unverified), arm64 build.
- `docker buildx bake --print` passed; `image-local` build and test results stated honestly.
