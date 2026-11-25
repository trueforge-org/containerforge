# xwiki — implementation plan
> Source: ./draft.md · Target: apps/xwiki/ · Difficulty: hard · Role (main/sidecar): main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | 18.9.0 (stable). Maven `<release>` reports 18.10.0-rc-1, which is an RC, so it is not used. Source: https://maven.xwiki.org/releases/org/xwiki/platform/xwiki-platform-distribution-war/maven-metadata.xml |
| Draft tag | Draft pins 18.9.0; matches. |
| Renovate | Proposed: `datasource=maven depName=org.xwiki.platform:xwiki-platform-distribution-war versioning=loose`. UNVERIFIED: that this repo's renovate config accepts the maven datasource for WAR files. |
| License | LGPL-2.1 (image label in https://raw.githubusercontent.com/xwiki/xwiki-docker/589e96c134218b1e1d6dab64865aade428ae1106/18/postgres-tomcat/Dockerfile; LICENSE text at https://raw.githubusercontent.com/xwiki/xwiki-docker/master/LICENSE) |
| Source | https://github.com/xwiki/xwiki-platform |
| Per-arch downloads | WAR (arch-neutral): https://maven.xwiki.org/releases/org/xwiki/platform/xwiki-platform-distribution-war/18.9.0/xwiki-platform-distribution-war-18.9.0.war (HTTP 200, 342050683 bytes). JDBC (arch-neutral): https://repo1.maven.org/maven2/org/postgresql/postgresql/42.7.14/postgresql-42.7.14.jar. LibreOffice 26.2.7: amd64 https://download.documentfoundation.org/libreoffice/stable/26.2.7/deb/x86_64/LibreOffice_26.2.7_Linux_x86-64_deb.tar.gz; arm64 https://download.documentfoundation.org/libreoffice/stable/26.2.7/deb/aarch64/LibreOffice_26.2.7_Linux_aarch64_deb.tar.gz (HTTP 200). Tomcat 10.1.62: https://downloads.apache.org/tomcat/tomcat-10/v10.1.62/bin/apache-tomcat-10.1.62.tar.gz |
| Checksums | WAR sha256 `e15f79ad379cca52cdeb22035c2fd4d04aad8b18acefbe429e770943bde2c823` (pinned upstream, re-computed on the downloaded file: match). JDBC sha256 `73914527305a40cce504b0d3d90b23caf565136912d607ae8ae7c5895512332c` (match). LibreOffice amd64 sha256 `8cd04a88396a9230264ff784ec89cc090cbfd0960c192483ba2b80fa53939416` (match). LibreOffice arm64 sha256 `d871da75fe387f9dab5acb7569d46d1098835c25b53695c89152f5194ad34411` (pinned upstream; UNVERIFIED, arm64 tarball not downloaded). Tomcat: sha512 file published at https://downloads.apache.org/tomcat/tomcat-10/v10.1.62/bin/apache-tomcat-10.1.62.tar.gz.sha512 (tarball not re-hashed, UNVERIFIED locally). |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/xwiki/xwiki-docker/589e96c134218b1e1d6dab64865aade428ae1106/18/postgres-tomcat/Dockerfile (base `tomcat:10-jre25`; apt curl unzip procps libxtst6 libxi6 libxinerama1 libdbus-glib-1-2 libcairo2 libcups2 libsm6 libx11-xcb1 libnss3 libxml2-dev libxslt1.1; LibreOffice into /opt with /opt/libreoffice symlink; WAR unzipped into /usr/local/tomcat/webapps/ROOT; JDBC copied into WEB-INF/lib; `VOLUME /usr/local/xwiki`; ENTRYPOINT docker-entrypoint.sh, CMD xwiki) |
| Env vars (real, from upstream docker-entrypoint.sh) | DB_USER (xwiki), DB_PASSWORD (xwiki), DB_DATABASE (xwiki), DB_HOST (db), DB_PORT (5432), CONTEXT_PATH (ROOT), JDBC_PARAMS, JAVA_OPTS, CATALINA_TMPDIR (default /usr/local/xwiki/data/tmp). Source: https://raw.githubusercontent.com/xwiki/xwiki-docker/589e96c134218b1e1d6dab64865aade428ae1106/18/postgres-tomcat/xwiki/docker-entrypoint.sh |
| Ports | 8080/tcp (Tomcat default). UNVERIFIED for this image: upstream does not EXPOSE. |
| Data/config write paths | `/usr/local/xwiki` (permanent dir, VOLUME upstream); `/usr/local/xwiki/data/tmp` (emptied each start); `/usr/local/tomcat/webapps/ROOT` (configure step writes hibernate.cfg.xml, xwiki.cfg, xwiki.properties, marker file). |
| arm64 | Upstream builds for amd64 and arm64 (LibreOffice arch branch). Our arm64 is UNVERIFIED until a build runs. |
| Dependencies | postgresql (exists as apps/postgresql, hard dependency) |
| Blockers | No Tomcat in apps/java25 base: we must install Tomcat 10.1.62 ourselves. LibreOffice needs `dpkg -i` as root. Large image. |

## 2. Target layout

- `apps/xwiki/Dockerfile`
- `apps/xwiki/docker-bake.hcl`
- `apps/xwiki/settings.yaml`
- `apps/xwiki/container-test.yaml`
- `apps/xwiki/start.sh` (replaces upstream docker-entrypoint.sh; seeds config into /config, then execs Tomcat)
- `apps/xwiki/defaults/` only if we ship default xwiki.cfg / hibernate.cfg.xml templates (reason: the upstream first-start configuration is generated from templates, so they must be in the image; `defaults/` is allowed by include/.dockerignore). Not `root/`.
- `apps/xwiki/DOWNSTREAM_CHANGES.md`: not applicable (not a FROM base).

## 3. Base image

`FROM ghcr.io/trueforge-org/java25:25.0.1@sha256:22a0f8a73c79e2f733c7513aefceef24ab8a213fd35af0ab1946996efc21636d` for the final stage, with the ubuntu base underneath. Fits because upstream runs JRE 25 (tomcat:10-jre25). Closest sibling: apps/airsonic-advanced (Tomcat-style WAR on a java base, port 4040). Java base has no Tomcat, so Tomcat must be installed. Build stage can use `ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454` for the download/verify step, and the final stage copies /usr/local/tomcat and /opt/libreoffice with `COPY --from=`.

## 4. Dockerfile

1. Build stage on ubuntu base, `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. Download WAR, JDBC jar and Tomcat tarball; verify each with `sha256sum --strict -c` (values in section 1). Tomcat: verify sha512 against the published file.
3. LibreOffice: select tarball by `dpkg --print-architecture` (amd64 -> x86_64/x86-64, arm64 -> aarch64) and verify sha256 with the pins above; extract to /tmp.
4. Final stage `FROM java25 base` with `USER root`: apt `--no-install-recommends` for libxtst6 libxi6 libxinerama1 libdbus-glib-1-2 libcairo2 libcups2 libsm6 libx11-xcb1 libnss3 libxml2 libxslt1.1 procps curl unzip. Do NOT reinstall packages the base already has (check first). Pin versions only if taken from apt and checked against VERSION. Install the LibreOffice debs with `dpkg -i` from /tmp, then `ln -fns /opt/libreoffice26.2 /opt/libreoffice` and `test -x /opt/libreoffice/program/soffice`.
5. Tomcat: extract to /app/tomcat is NOT allowed for writes at runtime; keep read-only files under /usr/local/tomcat (build-time) and make `temp`, `work`, `logs` point to /tmp via CATALINA_TMPDIR/CATALINA_BASE handling in start.sh (no writes to /app).
6. WAR: unzip to /usr/local/tomcat/webapps/ROOT; copy JDBC to WEB-INF/lib; patch logback as upstream does only if we keep the file-log appender (otherwise log to stdout). License: LGPL-2.1 text to /usr/share/licenses/xwiki/LICENSE.
7. `ENV` moving caches and temp off /config: `CATALINA_TMPDIR=/tmp/xwiki-tmp`, `HOME=/config`, `LANG=en_US.UTF-8` only if needed (java base already sets it).
8. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE 8080
VOLUME /config
```

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "xwiki" }
variable "VERSION" {
  // renovate: datasource=maven depName=org.xwiki.platform:xwiki-platform-distribution-war versioning=loose
  default = "18.9.0"
}
variable "LICENSE" { default = "LGPL-2.1-only" }
variable "SOURCE" { default = "https://github.com/xwiki/xwiki-platform" }
```

Plus the four standard targets and default group copied from apps/adguardhome-sync. Check `docker buildx bake --print` before any build. The Dockerfile `ARG VERSION` must equal 18.9.0.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/xwiki/xwiki-platform"
ports:
  - port: 8080
    protocol: tcp
    required: true
env:
  - name: DB_USER
    default: "xwiki"
    required: false
  - name: DB_PASSWORD
    default: "xwiki"
    required: false
  - name: DB_DATABASE
    default: "xwiki"
    required: false
  - name: DB_HOST
    default: "postgresql"
    required: false
  - name: DB_PORT
    default: "5432"
    required: false
  - name: CONTEXT_PATH
    default: "ROOT"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies:
  - postgresql
```

Only variables the upstream entrypoint actually reads are listed; JAVA_OPTS and JDBC_PARAMS may be added. `DB_HOST` default `postgresql` is our choice (UNVERIFIED against apps/postgresql service name); upstream default is `db`.

## 7. start.sh

- Idempotent. Seed `/config/xwiki` (permanent dir) only when missing; never write under /app or the WAR path if read-only.
- Create `/tmp/xwiki-tmp` each start; export `CATALINA_TMPDIR` to it.
- Apply DB_* values to hibernate.cfg.xml on every start (rendered from templates in `defaults/`), writing to /tmp then copying to the config path; keep DB_PASSWORD out of the process list.
- Make XWiki permanent directory point to `/config` (xwiki.cfg `xwiki.store.permanentDirectory` set to /config/xwiki).
- Bind Tomcat to 0.0.0.0 on 8080 (default server.xml binds all interfaces; verify).
- Final line: `exec catalina.sh run`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
timeoutSeconds: 300
tcp:
- port: '8080'
http:
- port: '8080'
  path: /
filePaths:
- /usr/share/licenses/xwiki/LICENSE
- /usr/local/tomcat/webapps/ROOT/WEB-INF/lib/postgresql-42.7.14.jar
- /opt/libreoffice/program/soffice
```

Test runs with no DB. Narrowing per the protocol's database-dependent exception applies: add the comment `# narrowed: requires external postgresql; full functional test not feasible in single-container suite` near the http probe. The exception applies only if all three criteria hold (hard dependency on postgresql: yes; will not start without DB: to be confirmed in step 3; not feasible in single-container suite: yes).

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/usr/local/xwiki` (permanent dir, VOLUME) | `/config/xwiki` (persistent, seeded only if missing) |
| `/usr/local/xwiki/data/tmp` (java.io.tmpdir, CATALINA_TMPDIR) | `/tmp/xwiki-tmp` (recreated each start) |
| `/usr/local/tomcat/webapps/ROOT/WEB-INF/hibernate.cfg.xml`, `xwiki.cfg`, `xwiki.properties` (configure step) | Rendered to /tmp and read via env/system property; if the WAR path is read-only, use the upstream recommended per-file bind-mount approach (UNVERIFIED for our layout) |
| Tomcat `temp`, `work`, `logs` | `/tmp` via CATALINA_BASE or -D properties |
| Upstream runs as root (chart runAsUser 0) | Final stage `USER apps`; draft security expectation (root, readOnlyRootFilesystem false) is NOT inherited. Target: rootless, read-only rootfs. |
| Extra persistence in chart (/usr/local/xwiki pvc) | Replaced by /config (draft's /config is correct for our model) |

Privileged: not needed. UID: apps (ContainerForge standard).

## 10. Risks, caveats and open questions

- Setup wizard: first start needs manual wizard completion in the UI (upstream and draft agree). Start must not block on it.
- LibreOffice adds size and startup time (inferred).
- Tomcat and JVM need about 1 GB or more; upstream default -Xmx1024m (verified in setenv.sh); draft's "2 GB or more" is inferred.
- Version upgrades need DB migration: tags cannot be swapped blindly.
- Tomcat is not in the java25 base; installing it adds a second version source to track (renovate for Tomcat tarball is UNVERIFIED).
- LibreOffice arm64 pin is UNVERIFIED (not downloaded).
- Blockers: none that are musl-only, GPU or privileged. Read-only rootfs compatibility is the main risk.

## 11. Build and test steps

```sh
cd apps/xwiki
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create xwiki-probe-config
docker run --rm -d --name xwiki-probe --read-only --tmpfs /tmp -v xwiki-probe-config:/config xwiki:18.9.0
docker logs -f xwiki-probe
docker rm -f xwiki-probe; docker volume rm xwiki-probe-config
forgetool containers test --image xwiki:18.9.0 --config ./apps/xwiki/container-test.yaml
```

Expected readiness signal: Tomcat log line `Server startup in [N] milliseconds` (UNVERIFIED for this build). Run the DB path separately with a postgresql container on the same network to confirm the setup wizard reaches a 200 response.

## 12. PR checklist

- Branch `feat/add-xwiki`, commit `feat(xwiki): add new container`, title same.
- Body uses `.github/PULL_REQUEST_TEMPLATE.md`, sections and checkboxes kept; only check boxes that apply.
- Notes section contains `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign it).
- State what was not tested: arm64 build, DB-backed setup wizard, LibreOffice arm64 pin, Tomcat tarball hash, unless actually run.
