# fleet — implementation plan
> Source: ./draft.md · Target: apps/fleet/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | 2.3.3 (GitHub release tag https://github.com/linuxserver/fleet/releases/tag/2.3.3). Chart image is `ghcr.io/linuxserver/fleet:2.3.3`. |
| Project identity | **The draft's docs and website links (fleetdm.com) are for a different product.** The jar is `io.linuxserver.fleet.core.Main` from https://github.com/linuxserver/fleet, and linuxserver's readme-vars (https://raw.githubusercontent.com/linuxserver/docker-fleet/68995eabc52afa0c3a1fddf3c5dbc803d6943c36/readme-vars.yml) describes it as "an online web interface which displays a set of maintained images from one or more owned repositories". Use the linuxserver/fleet repo as `SOURCE`. |
| Release date | 2022-10-30 (release page, single timestamp). |
| Renovate | `datasource=github-releases depName=linuxserver/fleet versioning=semver` |
| License | GPL-3.0 text in the LICENSE of https://github.com/linuxserver/docker-fleet (verified on the tarball at 68995eabc52afa0c3a1fddf3c5dbc803d6943c36). The linuxserver/fleet repo itself reports GPL-3.0 (GitHub API `license.spdx_id`, `LICENSE` file present, checked 2026-11-26), so use `GPL-3.0` for the jar. |
| Source URL | https://github.com/linuxserver/fleet |
| Download | https://github.com/linuxserver/fleet/releases/download/2.3.3/fleet-2.3.3.jar (only asset; 16149488 bytes). |
| Arch | Pure Java jar, arch-neutral. amd64 and arm64: yes. Native libraries inside the jar were not searched. |
| Java version | Class files in the jar are major 52 and 55 (Java 8 and 11). java17 runs them (the draft's pick). |
| Checksum source | None on the release page. Local sha256 of the downloaded jar: `fa9e6cbaa796a41366c85e36507ff4a287d322c4907f792e9eaeb8b6acf0507a`. Our own pin, not an upstream checksum. |
| Copy-from | `no`. The linuxserver image is alpine (musl) and would not run on glibc ubuntu. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/linuxserver/docker-fleet/68995eabc52afa0c3a1fddf3c5dbc803d6943c36/Dockerfile: `FROM baseimage-alpine:3.21`, `apk add openjdk11-jre-headless`, `ENV fleet_database_driver="org.mariadb.jdbc.Driver" fleet_app_port=8080`, jar to `/app/fleet/fleet.jar`, `EXPOSE 8080`, `WORKDIR /app/fleet`. `Dockerfile.aarch64` differs only in the base tag (`arm64v8-3.21`). |
| Upstream run command | `/usr/bin/java -Dfleet.config.base=/config -Dlog4j2.formatMsgNoLookups=true -jar /app/fleet/fleet.jar` (root/etc/s6-overlay/s6-rc.d/svc-fleet/run). |
| Port | 8080/tcp (EXPOSE, `fleet_app_port` default, and the chart's targetPort). |
| Env vars (real) | `fleet_admin_authentication_type` (DATABASE or PROPERTIES; DATABASE in the chart), `fleet_database_url` (`jdbc:mariadb://<host>:3306/fleet`), `fleet_database_username`, `fleet_database_password`, optional `fleet_admin_secret`, plus image defaults `fleet_database_driver=org.mariadb.jdbc.Driver` and `fleet_app_port=8080`. Source: readme-vars.yml and the chart's values.yaml (https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/fleet/values.yaml). |
| Data path | `/config` (`-Dfleet.config.base=/config`). |
| Dependency | MariaDB, hard. The chart enables the `mariadb` dependency with user `fleet` and database `fleet`. ContainerForge `apps/mariadb` exists. |
| Deprecation notice | linuxserver `init-deprecate`: "We deprecated our Fleet container and Fleet application due to issues maintaining the necessary level of development." Expect no upstream fixes. |
| Chart security | `runAsUser: 0`, `readOnlyRootFilesystem: false`, persistence `/config`, extra `varrun` volume. |

## 2. Target layout

Files in `apps/fleet/`:
- `Dockerfile`
- `docker-bake.hcl`
- `settings.yaml`
- `container-test.yaml`
- `start.sh`

No `defaults/`, `etc/` or `health/`: the app creates its own state under `/config`. No `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/java17:17.0.16@sha256:efdc903d9ce0436b6207bc5a4e732d24a27231851975c999770fd8709a8316b8` (digest from `apps/nzbhydra2/Dockerfile`). It fits because the app is one jar that runs on Java 17. Closest sibling: `apps/nzbhydra2` (digest verified in `apps/nzbhydra2/Dockerfile`; single jar downloaded from a GitHub release into `/app`, `USER apps`, `VOLUME /config`). Check in the build that `java` is on `PATH` (`command -v java`), since the base layout is not checked here.

## 4. Dockerfile

1. `FROM` line above. `ARG VERSION`, `USER root`.
2. Download the jar to `/app/fleet` and verify it against our pinned sha256 (no upstream checksum):
   ```dockerfile
   ARG VERSION
   ARG FLEET_SHA256="fa9e6cbaa796a41366c85e36507ff4a287d322c4907f792e9eaeb8b6acf0507a"
   RUN mkdir -p /app/fleet \
    && curl -fsSL -o /app/fleet/fleet.jar \
         "https://github.com/linuxserver/fleet/releases/download/${VERSION}/fleet-${VERSION}.jar" \
    && echo "${FLEET_SHA256}  /app/fleet/fleet.jar" | sha256sum -c - \
    && chown -R root:root /app/fleet \
    && chmod -R 755 /app/fleet
   ```
   Keep `FLEET_SHA256` in step with `VERSION`. Do not add an apt package: the base already ships Java 17 (verify in the build).
3. License: download the repo `LICENSE` at tag 2.3.3 (`https://raw.githubusercontent.com/linuxserver/fleet/${VERSION}/LICENSE`, UNVERIFIED that it exists at that tag) into `/usr/share/licenses/fleet/LICENSE`, and add it to `filePaths`.
4. Env defaults that match the image: `ENV fleet_database_driver="org.mariadb.jdbc.Driver" fleet_app_port=8080 fleet_admin_authentication_type=DATABASE`.
5. Tail:
   ```dockerfile
   USER apps
   COPY --chmod=0755 . /
   WORKDIR /config
   EXPOSE 8080
   VOLUME /config
   ```

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "fleet"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=linuxserver/fleet versioning=semver
  default = "2.3.3"
}

variable "LICENSE" {
  default = "GPL-3.0"
}

variable "SOURCE" {
  default = "https://github.com/linuxserver/fleet"
}
```
Then the default group, `image`, `image-local` and `image-all` targets copied from `apps/nzbhydra2/docker-bake.hcl`. Validate with `cd apps/fleet && docker buildx bake --print`. `VERSION` must equal the Dockerfile `ARG VERSION`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/linuxserver/fleet"
ports:
  - port: 8080
    protocol: tcp
    required: false
env:
  - name: fleet_admin_authentication_type
    default: "DATABASE"
    required: false
  - name: fleet_app_port
    default: "8080"
    required: false
  - name: fleet_database_driver
    default: "org.mariadb.jdbc.Driver"
    required: false
  - name: fleet_database_username
    default: "fleet"
    required: false
  - name: fleet_database_url
    default: ""
    required: true          # no safe default: start.sh refuses to start without it
  - name: fleet_database_password
    default: ""
    required: true          # no safe default: start.sh refuses to start without it
  - name: fleet_admin_secret
    default: ""
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies:
  - name: mariadb
```
- `dependencies: mariadb` (`apps/mariadb` exists, checked). `opt_dependencies`: none.
- Every name above is read by the jar or set by the upstream image. `TZ` is included per sibling convention; drop it if the jar does not read it (UNVERIFIED).
- Required values: the `required: true` rule says a required variable needs a default or to be handled by start.sh. Empty defaults are not valid for a real default, so `start.sh` must check them and exit with a clear message. Confirm the schema accepts `default: ""` before relying on it (UNVERIFIED).

## 7. start.sh

```bash
#!/usr/bin/env bash

: "${fleet_database_url:?fleet_database_url is required (jdbc:mariadb://host:3306/fleet)}"
: "${fleet_database_password:?fleet_database_password is required}"

mkdir -p /config

exec \
    java \
        -Dfleet.config.base=/config \
        -Djava.io.tmpdir=/tmp \
        -Dlog4j2.formatMsgNoLookups=true \
        -jar /app/fleet/fleet.jar
```
- The DB URL and password are read by the jar from the environment, so they never appear in the process arguments or in files. Do not echo them.
- Idempotent: only creates `/config`. Nothing seeded; the jar writes its own state under `/config`.
- No writes to `/app`. The jar runs with its own working directory `/config` (WORKDIR).
- `exec` for signal handling.
- `fleet_app_port` default 8080 is read by the jar (UNVERIFIED that the jar reads it, since the image sets it as ENV; check in the run step by changing it).
- Set the `java` path explicitly if `command -v java` in the build shows it is not on `PATH`.

## 8. container-test.yaml

The app cannot start without a MariaDB, so the probe checks need a database that the single-container suite does not provide. Apply the narrowed exception (`.github/instructions/build-test-protocol.instructions.md`) only if all three criteria hold. Verify each before writing the test:
1. Hard dependency: yes (`dependencies: mariadb`).
2. Will not start or fail health without the DB: verify in the run step with no DB (expected: exit or failing health). UNVERIFIED until run.
3. Not feasible with the single-container primitives: check the forgetool schema (`pkg/containers/test/container-test.schema.json`) for a sidecar or service option. If none exists, the criterion holds.

If all three hold, the planned test is:

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 180
# narrowed: requires external mariadb; full functional test not feasible in single-container suite
filePaths:
- /app/fleet/fleet.jar
runners:
- entrypoint: java -version
```

If a sidecar is possible, use it and write the full `tcp` (8080) and `http` (`/`) probes instead, which is the preferred outcome. Do not use an always-true check. The `tcp` probe on 8080 is only meaningful if the jar binds before the DB connects (UNVERIFIED).

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `-Dfleet.config.base=/config` (state, config, logs) | `/config` |
| JVM temp (`java.io.tmpdir`) | `/tmp` (set explicitly in start.sh) |
| `/app/fleet` | read-only at runtime; the jar is never written |
| `varrun` volume in the chart | Not needed: nothing in the upstream image writes there (UNVERIFIED). Do not add it. |
| Runtime user | `USER apps` (uid 568). Linuxserver runs as root and drops to `abc`; ContainerForge runs the app as `apps`. |

Run with `--read-only --tmpfs /tmp` and an empty `/config` volume. Confirm in the run step that the jar writes only under `/config` and `/tmp` (UNVERIFIED).

## 10. Risks, caveats and open questions

- **Wrong upstream in the draft.** The fleetdm.com docs and website links in the draft refer to a different product. The plan uses linuxserver/fleet. Correct the draft's links, or the PR description, before it is used for anything else.
- **Deprecated upstream.** linuxserver deprecated Fleet in 2.3.3 (banner in the upstream image). Mention this in the PR.
- **License.** GPL-3.0 per the GitHub API for linuxserver/fleet; confirm the `LICENSE` file at the 2.3.3 tag.
- **MariaDB dependency.** Full functional testing needs a MariaDB. The single-container suite cannot provide it; the narrowed test is the fallback (section 8). Run the functional check by hand with `apps/mariadb` on the same Docker network, and say so in the PR.
- **Required env values.** `fleet_database_url` and `fleet_database_password` have no default; `start.sh` refuses to start without them. The schema behaviour for empty defaults is UNVERIFIED.
- **Admin setup.** The first admin is created in the web UI (manual setup). Agents need a TLS endpoint to connect; that is the user's responsibility, not the container's.
- **Java version.** The jar targets Java 8/11 class files; java17 is the chosen base. Java 21 (`apps/java21`) would also work and is the fallback if java17 fails at run.
- **arm64 not built here.** Pure Java, so arm64 should work, but it is not run here.

## 11. Build and test steps

Run from `apps/fleet` (protocol: `.github/instructions/build-test-protocol.instructions.md`):

1. `docker buildx bake --print` (must exit 0).
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`.
3. Start with no DB to confirm the required-env guard and the DB dependency (expected: clear error, no crash loop):
   ```sh
   docker volume create fleet-probe-config
   docker run --rm --name fleet-probe --read-only --tmpfs /tmp \
     -v fleet-probe-config:/config fleet:2.3.3
   docker rm -f fleet-probe; docker volume rm fleet-probe-config
   ```
4. Start with a scratch `apps/mariadb` on a shared network (`docker network create fleet-net`), with `fleet_database_url=jdbc:mariadb://<mariadb-container>:3306/fleet`, `fleet_database_username=fleet`, `fleet_database_password` from a scratch value, `--read-only --tmpfs /tmp`, and an empty `/config`. Expected readiness: the Java process stays up, the log shows the Fleet startup line on port 8080 (UNVERIFIED text until run), and no fatal exception. Check `ss -ltn` for 8080.
5. `forgetool containers test --image fleet:2.3.3 --config ./apps/fleet/container-test.yaml`. If forgetool is not available, check the probes by hand.
6. Remove scratch containers, networks and volumes between rounds (round limit 10).

## 12. PR checklist

- Branch `feat/add-fleet`; commit `feat(fleet): add new container`; target `main`.
- PR title in Conventional Commits form: `feat(fleet): add new container`.
- PR description from `.github/PULL_REQUEST_TEMPLATE.md`, keeping its sections and checkboxes. Only check what applies.
- Notes section includes `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign it; the `license/cla` check shows the status).
- State what was not tested: the MariaDB-backed functional run (if not done), arm64 build, admin setup, and any UNVERIFIED behaviour (readiness text, `TZ` use, `fleet_app_port` use).
- Note that the upstream is linuxserver/fleet (deprecated), not fleetdm.com.
- Downstream check: none (not a `FROM` base).
