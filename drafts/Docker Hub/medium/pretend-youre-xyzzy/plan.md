# pretend-youre-xyzzy — implementation plan
> Source: ./draft.md · Target: apps/pretend-youre-xyzzy/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | No GitHub releases (https://api.github.com/repos/ajanata/PretendYoureXyzzy/releases/latest returns 404). Source only. Candidate pin: `master` HEAD `10525012c69c76d902148828ff946545563faf80` (committed 2026-10-23, read via the GitHub commits API in this run). The chart image is `cyb3rjak3/dockeryourxyzzy:on-demand-v2.1.1`, built from the Cyb3r-Jak3 Dockerfile. The version to pin is UNVERIFIED: pin a commit SHA of `ajanata/PretendYoureXyzzy` (`master`, last push 2026-10-23) and record it in `VERSION`. |
| Repository state | `ajanata/PretendYoureXyzzy`: archived=true, last push 2026-10-23, license BSD-2-Clause (https://api.github.com/repos/ajanata/PretendYoureXyzzy). The README says the project is retired and not maintained. |
| Packaging repo | `Cyb3r-Jak3/DockerYourXyzzy`: BSD-2-Clause, not archived, last push 2026-06-23, no releases (https://api.github.com/repos/Cyb3r-Jak3/DockerYourXyzzy). Its Dockerfile at `fade38c9e0b94c1294360a1f4697ab167dbd3d09` was reviewed (https://raw.githubusercontent.com/Cyb3r-Jak3/DockerYourXyzzy/fade38c9e0b94c1294360a1f4697ab167dbd3d09/Dockerfile, summary via WebFetch). |
| Renovate | UNVERIFIED: no release tags. Use `datasource=git-refs depName=https://github.com/ajanata/PretendYoureXyzzy currentValue=master` (precedent `apps/tvheadend/docker-bake.hcl`). Pin a SHA in `VERSION`. |
| License | BSD-2-Clause (GitHub SPDX). |
| Source URL | https://github.com/ajanata/PretendYoureXyzzy |
| Binary | None. No prebuilt WAR is published. Build from source (Maven). |
| Build (upstream README) | `mvn clean package war:war` in the project directory. Alternate: `mvn clean package war:exploded jetty:run` with `-Dmaven.buildNumber.doCheck=false -Dmaven.buildNumber.doUpdate=false`. Source: https://raw.githubusercontent.com/ajanata/PretendYoureXyzzy/master/README.md. |
| Upstream builder stage | Cyb3r image `builder`: `FROM base`, `apk add git`, clones `/project`, renames `build.properties.example` to `build.properties`, runs `mvn compile war:war` with `-Dhttps.protocols=TLSv1.2 -Dmaven.buildNumber.doCheck=false -Dmaven.buildNumber.doUpdate=false`. Output `target/ZY.war`. |
| Maven | Cyb3r image: `ARG MAVEN_VERSION=3.9.6`, SHA-512 verified against an upstream sum (`ARG SHA`, value not captured here), installed to `/usr/share/maven`, `/usr/bin/mvn` symlink. |
| Runtime used upstream | Cyb3r `base`: `ghcr.io/cyb3r-jak3/alpine-tomcat:11-jdk-10.1.17` (Tomcat 10.1.17, JDK 11, alpine). Cyb3r `prebuilt`: `jetty:11-jre11-slim`, `COPY --from=builder /project/target/ZY.war /var/lib/jetty/webapps/ROOT.war`, `CMD ["java","-jar","/usr/local/jetty/start.jar"]`. |
| Ports | 8080/tcp. The README's Docker example maps `-p 8080:8080` (README above). Cyb3r image has no `EXPOSE`. |
| Java version | UNVERIFIED. The README says "This project is only known to work with Tomcat 7, all other versions are unsupported." That conflicts with the Cyb3r image (Tomcat 10.1, JDK 11). The Java version the WAR needs is not confirmed. The draft's `java17` default is also UNVERIFIED. |
| Config | `build.properties`, key `geoip.db` points to a GeoLite2-City file (optional, GeoIP features only). README above. |
| Data path | UNVERIFIED: the game state and card database location. The draft says `/config`, not confirmed in the fetched README. |
| Env vars | None mentioned in the README. Cyb3r image sets `USER_HOME_DIR=/root` and `GIT_BRANCH=master` (build only). |
| User / volumes | Cyb3r image: no `USER`. `on-demand` declares `VOLUME /overrides` (not needed by us). |
| Dependencies | None in the Dockerfile or README. |

## 2. Target layout

- `apps/pretend-youre-xyzzy/Dockerfile`
- `apps/pretend-youre-xyzzy/docker-bake.hcl`
- `apps/pretend-youre-xyzzy/settings.yaml`
- `apps/pretend-youre-xyzzy/container-test.yaml`
- `apps/pretend-youre-xyzzy/start.sh`
- `apps/pretend-youre-xyzzy/defaults/` only if a default `build.properties` or seed file is needed (reason: `/config` seeding on empty start). Otherwise omit.

No `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base). Keep the schema header in `settings.yaml` and `container-test.yaml`.

## 3. Base image

Draft: `java17` runtime. Recommended: the Java stack that matches what upstream was run on, which is JDK 11 with Tomcat 10.1. Pick between two options after the first build, not before:

- Option A (recommended for the first build): `FROM ghcr.io/trueforge-org/java11:<tag>@<digest>`. No downstream app uses `ghcr.io/trueforge-org/java11` yet (UNVERIFIED tag and digest): take them from the published java11 image for `apps/java11` (bake `VERSION` `11.0.29+7`) and copy the form used by `apps/doplarr` for java21. `apps/java11/Dockerfile` itself is built `FROM` the ubuntu base, so do not copy its `FROM` line. JDK 11 matches the Cyb3r image, and the Tomcat runtime is installed separately.
- Option B (draft default): `apps/java17`. Use only if the build fails on JDK 11 (the project's Maven and javac target are UNVERIFIED).

Build stage: `FROM ghcr.io/trueforge-org/java<N>` as the build image too (it has JDK; confirm `javac` and `mvn` are in it, or install Maven in the build stage). Closest siblings: `apps/nzbhydra2` and `apps/airsonic-advanced` (Java apps on the java base). Whether either uses a Tomcat or Jetty pattern is UNVERIFIED; check their `Dockerfile` before writing.

## 4. Dockerfile

1. `ARG VERSION` (commit SHA), `ARG MAVEN_VERSION=3.9.6`, `ARG TARGETARCH`, `USER root`.
2. Build stage `FROM <java-base> AS build`. Install `curl` and `unzip` if missing (check the base first, do not reinstall base packages). Maven: `curl -fsSL https://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz`, verify against the SHA-512 from `https://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz.sha512` (the sum is UNVERIFIED in this run; fetch and check it before pinning). Install to `/tmp/maven`, not `/app`.
3. Source at the pinned SHA: `curl -fsSL https://github.com/ajanata/PretendYoureXyzzy/archive/${VERSION}.tar.gz | tar xz -C /tmp/src --strip-components=1`.
4. `cp build.properties.example build.properties` (as upstream) and set `geoip.db` only if GeoIP is wanted (UNVERIFIED default: keep the example value).
5. `mvn -B clean package war:war -Dhttps.protocols=TLSv1.2 -Dmaven.buildNumber.doCheck=false -Dmaven.buildNumber.doUpdate=false` with `MAVEN_OPTS` and `HOME=/tmp` so the local repo lands in `/tmp`.
6. Runtime stage: `FROM <java-base>` (same as build, or a JRE if the base offers one). Servlet container: UNVERIFIED decision. Recommended: Tomcat 10.1.x (matches the upstream image, not Tomcat 7 as the README says) from `archive.apache.org` with its SHA-512, installed to `/usr/local/tomcat` (read-only at runtime, `/app` is not used, so use `/app/tomcat`). Deploy `target/ZY.war` as `ROOT.war` into `webapps/`. Only `ROOT.war`, the rest of Tomcat's `webapps` removed.
7. Licence: `COPY --from=build /tmp/src/LICENSE /usr/share/licenses/pretend-youre-xyzzy/LICENSE` (confirm the file path in the repo).
8. `chown -R root:root /app && chmod -R 755 /app`. `rm -rf /tmp/*` in the stage.
9. `USER apps`, `COPY --chmod=0755 . /`, `WORKDIR /config`.
10. `EXPOSE 8080`, `VOLUME /config`, `ENV CATALINA_HOME=/app/tomcat CATALINA_BASE=/config/tomcat`.

Tomcat's `CATALINA_BASE` under `/config` is a writable tree, so `start.sh` seeds it (section 7).

## 5. docker-bake.hcl

- `variable "APP" { default = "pretend-youre-xyzzy" }`
- `variable "VERSION"` with `// renovate: datasource=git-refs depName=https://github.com/ajanata/PretendYoureXyzzy currentValue=master` and `default = "<40-char SHA>"`. Use the SHA that was built, not a branch name.
- `variable "LICENSE" { default = "BSD-2-Clause" }`
- `variable "SOURCE" { default = "https://github.com/ajanata/PretendYoureXyzzy" }`
- `docker-metadata-action`, `group "default"` (`image-local`), `image` (args `VERSION`, labels for source and licenses), `image-local` (`type=docker`, tag `${APP}:${VERSION}`), `image-all` (`linux/amd64`, `linux/arm64`). Mirror `apps/sonarr/docker-bake.hcl`.
- Note: a 40-char SHA makes the tag long. If that is a problem, keep the full SHA in `VERSION` and use a `short` tag in `image-local` (the sibling pattern decides; check `apps/` for a SHA-pinned app first).
- Validate with `docker buildx bake --print` from `apps/pretend-youre-xyzzy`.

## 6. settings.yaml

- Schema header from siblings, `schema_version: 1`, `upstream_env_url: https://github.com/ajanata/PretendYoureXyzzy`.
- `ports`: `8080` (http, required true).
- `env`: none confirmed. Leave out until the app reads a variable. Do not invent names.
- `volumes`: `/config` (game state, card DB, Tomcat base).
- `dependencies`: none.

## 7. start.sh

- `#!/bin/sh`, `set -eu`.
- Seed `/config/tomcat` (the `CATALINA_BASE`) only when missing: `conf/`, `logs/`, `temp/`, `webapps/` from `/app/tomcat`. Do not overwrite existing files. Create `temp` and `logs` with `mkdir -p`.
- Set `CATALINA_TMPDIR=/tmp` (Tomcat temp must not be in `/config`).
- If the app needs its own data dir, create `/config/data` only when missing (UNVERIFIED path).
- Copy `build.properties` only if it does not exist (UNVERIFIED that the app reads it from the WAR's classpath; if so, nothing to copy at runtime).
- Bind all interfaces: Tomcat `conf/server.xml` `Connector port="8080"` defaults to `address` unset (all interfaces). Verify this in the seeded config and do not change it unless it binds localhost.
- Final command: `exec /app/tomcat/bin/catalina.sh run` with `CATALINA_BASE=/config/tomcat` and `CATALINA_HOME=/app/tomcat`.

## 8. container-test.yaml

- Schema header from siblings.
- `tcp` probe on `8080`.
- `http` probe on `8080` at `/` (the app's welcome page). Use a path confirmed on a running container (UNVERIFIED).
- `filePaths`: `/app/tomcat/webapps/ROOT.war` (or the exploded `ROOT/` dir), `/app/tomcat/bin/catalina.sh`.
- `timeoutSeconds`: those Java siblings (`apps/nzbhydra2`, `apps/airsonic-advanced`) set none; other Java apps (`apps/davos`, `apps/ubooquity`) use 180, so use 180. Tomcat with a WAR deploy takes time, so allow headroom.
- The test runs with no env. The app must start on an empty `/config`. There is no env path to hide.

## 9. Rootless and read-only-rootfs adaptations

| Upstream / chart | This plan |
| --- | --- |
| Chart `runAsUser 0`, `runAsNonRoot false` | `USER apps`. |
| Chart `readOnlyRootFilesystem: false` | Compatible: `/app` read-only, Tomcat base and state under `/config`, temp under `/tmp` (`CATALINA_TMPDIR`). |
| Cyb3r `prebuilt` `/var/lib/jetty/webapps/ROOT.war` | `/app/tomcat/webapps/ROOT.war`. |
| Cyb3r `on-demand` `VOLUME /overrides` | Dropped. The `settings-docker.xml` override is a build-time Maven setting, not runtime. |
| Maven `/root/.m2` | Build-only; `HOME=/tmp` for the build. Nothing from `/root` at runtime. |

## 10. Risks, caveats and open questions

- Repo is archived and retired upstream. No releases. Pin a commit SHA and say so in the PR.
- Provenance: the image the chart uses is third-party (`cyb3rjak3/dockeryourxyzzy`). We build from the upstream source, not from that image, so behaviour may differ.
- Servlet container and Java version conflict: README says Tomcat 7 only; the packaging image uses Tomcat 10.1 with JDK 11. Confirm by building and deploying. If the WAR is `javax` (Tomcat 7/9), Tomcat 10.1 will not run it and the plan must change to Tomcat 9.0.x (UNVERIFIED).
- Data path (game state, card DB): not confirmed in the README. Read the source before writing `start.sh`.
- Maven build needs internet access at build time (draft caveat, accepted).
- `build.properties.example` contents and `geoip.db`: UNVERIFIED defaults. GeoIP is optional.
- arm64: Tomcat and JDK builds exist for arm64; the WAR is architecture-independent. The base image for arm64 is not checked (UNVERIFIED).
- Blockers: none known. No privileged, GPU or hostPath need. The upstream `on-demand` mode is not used.

## 11. Build and test steps

From `apps/pretend-youre-xyzzy`, per `.github/instructions/build-test-protocol.instructions.md`:

1. `docker buildx bake --print` (must exit 0).
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`. Expect the Maven build to take several minutes.
3. Run with an empty config volume:
   `docker run --rm -d --name pretend-youre-xyzzy-probe --read-only --tmpfs /tmp -v pretend-youre-xyzzy-probe-config:/config pretend-youre-xyzzy:<VERSION>`, then `docker logs -f pretend-youre-xyzzy-probe`.
   Expected readiness signal: Tomcat's `Server startup in [N] milliseconds` line and `Starting ProtocolHandler ["http-nio-8080"]`, with the process still running.
4. Cleanup: `docker rm -f pretend-youre-xyzzy-probe; docker volume rm pretend-youre-xyzzy-probe-config`.
5. `forgetool containers test --image pretend-youre-xyzzy:<VERSION> --config ./apps/pretend-youre-xyzzy/container-test.yaml`.
6. Only if amd64 is green: `image-all` arm64 build as a separate check.

Not run in this planning step.

## 12. PR checklist

- Branch: `feat/add-pretend-youre-xyzzy`.
- Commit: `feat(pretend-youre-xyzzy): add new container`.
- PR title: `feat(pretend-youre-xyzzy): add new container`.
- Use `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections and checkboxes, and check only the boxes that apply.
- Notes section: `🤖 This PR is AI generated.`
- CLA notice: the contributor must sign the CLA at https://cla-assistant.io/trueforge-org/containerforge. Only the user can sign it. The `license/cla` check shows the status.
- Honest list of untested items: arm64, the Tomcat/Java version decision, the data path, and anything not built or run locally.
- Say in the PR that the upstream project is archived and the image is built from a pinned source commit, not taken from the third-party image.
