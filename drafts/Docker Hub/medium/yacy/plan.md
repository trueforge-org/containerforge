# yacy — implementation plan
> Source: ./draft.md · Target: apps/yacy/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | 1.942, from `https://download.yacy.net/` (listing shows `yacy_v1.942_202608150808_f9c4b9700.tar.gz`, previous `yacy_v1.941_202603291103_f0464e7fb.tar.gz`). The draft's tarball URL returns HTTP 200, `application/x-gzip`, 128734611 bytes. There is no GitHub release (`gh api repos/yacy/yacy_search_server/releases/latest` returns 404). |
| Renovate | UNVERIFIED: no GitHub release. The download listing is the only release source; a `regex` custom manager on `download.yacy.net` is needed (not confirmed). Alternative: track the `yacy/yacy_search_server` master commit (`datasource=git-refs`), but the tarball is not built from it. |
| License | UNVERIFIED for the SPDX id. GitHub API reports `NOASSERTION` (https://github.com/yacy/yacy_search_server). Read `LICENSE` in the tarball (YaCy is GPL-2.0-or-later per its project docs; UNVERIFIED, not fetched). |
| Source URL | https://github.com/yacy/yacy_search_server |
| Download | `https://download.yacy.net/yacy_v1.942_202608150808_f9c4b9700.tar.gz`. Arch-neutral Java tarball (JVM), so amd64 and arm64 both use it. Native code in the tarball is UNVERIFIED. |
| Checksum source | UNVERIFIED: no `.sha256` or `.sha1` alongside the tarball was seen on the listing. Look for one in step 4; if none, record the SHA-256 of the fetched file in the Dockerfile comment and say so in the PR. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/yacy/yacy_search_server/eba3f94b4376180de5fbf3812c41e3c65dad4cfb/docker/Dockerfile. Builder and runtime `eclipse-temurin:24-jdk-noble`. Builder runs `ant compile` and removes `.git`. Final stage: `COPY --chown=yacy:yacy --from=builder /opt/yacy_search_server`. USER `yacy`. WORKDIR `/opt`. EXPOSE 8090, 8443. VOLUME `/opt/yacy_search_server/DATA`. CMD `/bin/sh /opt/yacy_search_server/startYACY.sh -f`. No ENV, no ENTRYPOINT. The build edits `defaults/yacy.init` with `sed` (admin hash, `adminAccountForLocalhost=false`, `server.https=true`). |
| Ports | 8090 (HTTP web UI and API), 8443 (HTTPS). Both confirmed by upstream EXPOSE. |
| Env vars | None defined upstream. The draft lists none; do not invent any. |
| Data paths | `/opt/yacy_search_server/DATA` (VOLUME, upstream). Config in `/opt/yacy_search_server/defaults/yacy.init` (edited at build time). |
| Java | Upstream JDK 24 (`eclipse-temurin:24-jdk-noble`). Whether YaCy 1.942 runs on Java 25 is UNVERIFIED (not tested). |
| Admin password | Upstream comment says the admin password is `yacy`. Do not ship that default. See section 7. |
| Discovery | UDP and multicast peer discovery (draft caveat, inferred; UNVERIFIED for this release). |

## 2. Target layout

- `apps/yacy/Dockerfile`
- `apps/yacy/docker-bake.hcl`
- `apps/yacy/settings.yaml`
- `apps/yacy/container-test.yaml`
- `apps/yacy/start.sh` (seeds `/config` and starts YaCy, see section 7)
- `apps/yacy/defaults/` only if a changed `yacy.init` template is needed (reason: the upstream build edits it; the port must reproduce the edits as a template, not as a `sed` at runtime).

No `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/java25:25.0.1@sha256:22a0f8a73c79e2f733c7513aefceef24ab8a213fd35af0ab1946996efc21636d`. The draft's reasoning holds: upstream is JDK 24, and java25 is the newest listed base. Alternative: `ghcr.io/trueforge-org/java21:21` (copy its FROM line from `apps/java21/Dockerfile`) only if java25 fails the build or the run (UNVERIFIED).

Closest sibling: `apps/java25` pattern (JRE tarball into `/opt/java/openjdk`, `USER apps`), and the Java apps `apps/nzbhydra2` and `apps/airsonic-advanced` for the `/config` and `start.sh` pattern.

Not used: `eclipse-temurin:24-jdk-noble` (upstream). It is not a ContainerForge base, and Ubuntu noble is not the ubuntu 26.04 base.

## 4. Dockerfile

1. `FROM <java25 digest>`, `ARG VERSION`, `USER root`.
2. Download and verify, without a build stage (the tarball is prebuilt):
   ```sh
   curl -fL -o /tmp/yacy.tar.gz https://download.yacy.net/yacy_v${VERSION}.tar.gz
   # checksum: UNVERIFIED source. If a published .sha256 exists, verify with sha256sum -c.
   tar xzf /tmp/yacy.tar.gz -C /app --no-same-owner
   ```
   Where `VERSION` is the full name token from bake (see section 5). `${VERSION}` for the file name needs the timestamp and hash parts, so keep the full token `1.942_202608150808_f9c4b9700` as the version.
3. Keep `LICENSE` from the tarball: `COPY` into `/usr/share/licenses/yacy/LICENSE` (inside the same RUN).
4. Move the app to `/app/yacy_search_server`. Remove Windows and macOS launchers (`*.exe`, `*.dmg`) if they are in the tarball; they are not used.
5. Data redirect: `ln -s /config/DATA /app/yacy_search_server/DATA` (dangling until start.sh creates it). Same pattern as the `fenrus` plan.
6. Caches and temp: `ENV JAVA_TOOL_OPTIONS=-Djava.io.tmpdir=/tmp`, `HOME=/tmp` or `/config` (HOME must not hold caches).
7. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE 8090 8443
VOLUME /config
WORKDIR /app/yacy_search_server
```

`WORKDIR` is needed because `startYACY.sh` resolves its paths from the current directory (UNVERIFIED: check the script). Make `/app/yacy_search_server` owned by root and read-only to `apps`.

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "yacy" }
variable "VERSION" {
  // renovate: datasource=custom.yacy depName=yacy_v versioning=loose
  default = "1.942_202608150808_f9c4b9700"
}
variable "LICENSE" { default = "GPL-2.0-or-later" }   // UNVERIFIED: confirm from LICENSE in the tarball
variable "SOURCE" { default = "https://github.com/yacy/yacy_search_server" }
```

The `renovate` datasource above is a placeholder: no built-in datasource tracks `download.yacy.net`. A `customManagers` regex in renovate config is needed, which is outside `apps/yacy/` and must not be changed from this PR. UNVERIFIED how the repo handles custom managers; check existing renovate config before choosing. Four standard targets and the default group copied from `apps/adguardhome-sync`. Run `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/yacy/yacy_search_server"
ports:
  - port: 8090
    protocol: tcp
    required: false
  - port: 8443
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

No runtime env vars are confirmed. Add `JAVA_OPTS`-style variables only if `start.sh` reads them, and only with a default. Dependencies: none (YaCy stores data on disk).

## 7. start.sh

Idempotent, runs as `apps`, writes only under `/config` and `/tmp`:

1. `mkdir -p /config/DATA`. Seed `/config/DATA` from the tarball's default `DATA` only when `/config/DATA` is missing or empty (YaCy creates the index on first run, so the empty case is normal).
2. Config: YaCy reads `defaults/yacy.init` at start and writes its runtime settings to `DATA/SETTINGS/yacy.conf` (UNVERIFIED path). Seed the runtime config in `/config` only when missing. Do not write to `defaults/` (read-only at runtime).
3. Admin password: do NOT ship the upstream `yacy` default. Read a value from an env var (name UNVERIFIED and to be added to `settings.yaml` with `required: true` and no default, or generate once and store it in `/config`). Decision needed from the maintainer; note it in the PR.
4. `adminAccountForLocalhost=false` and `server.https=true` (upstream build edits) are applied to the seeded config only, not to the image file.
5. Bind all interfaces: YaCy listens on `0.0.0.0` by default (UNVERIFIED for this release; check the log in step 11).
6. `cd /app/yacy_search_server && exec /bin/sh startYACY.sh -f` (foreground, so logs stay visible and PID 1 receives signals; `exec` as the start script rule requires).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 300
tcp:
- port: '8090'
http:
- port: '8090'
  path: /
filePaths:
- /app/yacy_search_server/startYACY.sh
- /app/yacy_search_server/lib
- /usr/share/licenses/yacy/LICENSE
```

YaCy's first start is slow (index and DATA creation; draft caveat), so `timeoutSeconds` is large. The sibling Java apps' values are the reference (check `apps/nzbhydra2/container-test.yaml`). Add an `8443` tcp probe only if HTTPS is on by default with no env var (UNVERIFIED); otherwise keep the 8090 probe and state it in the PR.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/opt/yacy_search_server/DATA` (VOLUME upstream) | `/config/DATA` via symlink (the draft's remap). |
| `defaults/yacy.init` (edited at build) | Reproduced as a seeded config in `/config`; the image copy stays unchanged at runtime. |
| JVM temp, tmp dirs | `/tmp` via `-Djava.io.tmpdir=/tmp`. |
| Log files | Written under `DATA/LOG` (UNVERIFIED): on `/config`, which is acceptable, or redirect to `/tmp` if large. |

Reconciling the draft's security expectations: the chart runs as UID 0 with `runAsGroup 0`, which is not needed (the image runs as `apps`, and ports 8090 and 8443 are above 1024). `readOnlyRootFilesystem` is possible with the remaps above and `--read-only --tmpfs /tmp`, once the log and temp paths are confirmed. Not privileged. Extra persistence: the chart's `/opt/yacy_search_server/DATA` PVC maps to `/config/DATA` here, so remap rather than add a volume. Existing users must move their data to `/config/DATA`.

## 10. Risks, caveats and open questions

- Admin password: upstream default `yacy`. Must not be shipped as a default (section 7).
- Java 24 on Java 25: UNVERIFIED. Test startup; fall back to java21 only if it fails and say so.
- Peer discovery needs UDP and multicast (draft caveat). Host networking may be needed for the node to join the network; the container alone will run as an isolated peer (UNVERIFIED for this release).
- First start creates a large index and data directory under `/config`: disk use and startup time can be significant (draft caveat).
- No checksum or renovate datasource: pin the file name token (the version) and add checksum verification only if an upstream checksum is published.
- Tarball size is 128 MB: the image is large; note it.
- The chart tag is rolling `latest` (draft caveat): pin `1.942` deliberately.
- No blockers identified for arm64 (JVM, arch-neutral tarball; confirm with bake `image-all`).

## 11. Build and test steps

```sh
cd apps/yacy
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name yacy-probe --read-only --tmpfs /tmp \
  -v yacy-probe-config:/config yacy:1.942_202608150808_f9c4b9700
docker logs -f yacy-probe
forgetool containers test --image yacy:1.942_202608150808_f9c4b9700 --config ./apps/yacy/container-test.yaml
docker rm -f yacy-probe; docker volume rm yacy-probe-config
```

Expected readiness signal: the process stays running, `Starting YaCy` or a similar banner appears (UNVERIFIED exact text), and the 8090 port answers. Confirm `/config/DATA` exists after start and survives a restart.

## 12. PR checklist

- Branch `feat/add-yacy`, commit and PR title `feat(yacy): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep sections, check only applicable boxes.
- Notes section includes `🤖 This PR is AI generated.`
- CLA: a signed Contributor License Agreement is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it; the `license/cla` check shows status.
- Untested (state honestly in the PR): Java 25 runtime with YaCy, peer discovery, the read-only run, the admin password handling, the checksum (if none published), and arm64.
- `docker buildx bake --print` passes; bake `VERSION` equals the Dockerfile `ARG VERSION`; no assertion weakened.
