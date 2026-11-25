# drawio — implementation plan
> Source: ./draft.md · Target: apps/drawio/ · Difficulty: hard · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | v32.7.4 (draft `jgraph/drawio:32.7.4`); `releases/latest` redirects to https://github.com/jgraph/drawio/releases/tag/v32.7.4. |
| Renovate | `datasource=github-releases depName=jgraph/drawio versioning=semver extractVersion=^v(?<version>.+)$` (tags have a `v` prefix). |
| License | Apache-2.0 (LICENSE at v32.7.4 is Apache License 2.0). Tomcat (Apache-2.0) is also shipped. |
| Source URL | https://github.com/jgraph/drawio |
| Downloads | The release has a prebuilt `draw.war`: https://github.com/jgraph/drawio/releases/download/v32.7.4/draw.war (found in the release's expanded assets; the page mentioned "Assets 3" but only that file name was listed in the HTML I parsed, so other assets UNVERIFIED). Architecture independent (Java). Tomcat 9 tarball from https://archive.apache.org/dist/tomcat/tomcat-9/ (exact 9.0.x UNVERIFIED, choose latest 9.0 and renovate it with `datasource=github-tags depName=apache/tomcat extractVersion` or the `maven` datasource, UNVERIFIED). |
| Checksum | draw.war: none published (UNVERIFIED). Tomcat: `.sha512` next to each tarball on apache.org. |
| Upstream Dockerfile reviewed | https://github.com/jgraph/docker-drawio/blob/d2e740b/main/Dockerfile: build stage `eclipse-temurin:11-jdk-jammy` with apt `ant git`, clones jgraph/drawio at depth 1 and runs `ant war` in `etc/build/`. Final stage `tomcat:9.0-jdk11-temurin` with apt `certbot curl xmlstarlet unzip`; unzips `draw.war` into `$CATALINA_HOME/webapps/draw` and edits `conf/server.xml` (xmlstarlet) so draw is the root Context. `ENV RUN_USER=tomcat RUN_GROUP=tomcat`; user tomcat UID 1001, `$CATALINA_HOME` chowned to group 0 with `g=u`; `EXPOSE 8080 8443`; `ENTRYPOINT /docker-entrypoint.sh`; `CMD catalina.sh run`. |
| Entrypoint facts | `docker-entrypoint.sh` (d2e740b) reads `LETS_ENCRYPT_ENABLED PUBLIC_DNS ORGANISATION_UNIT ORGANISATION CITY STATE COUNTRY_CODE KEYSTORE_PASS KEY_PASS DRAWIO_CSP_HEADER DRAWIO_GITLAB_ID DRAWIO_GITLAB_URL` and writes `webapps/draw/js/PreConfig.js`, so it needs a writable webapp dir. Only the first 40 lines were read; the full list of `DRAWIO_*` variables is UNVERIFIED. |
| Export server | The draft's port 8000 and headless Chromium come from an inferred "export server". The main upstream Dockerfile contains no export server. A separate project (jgraph/draw-image-export2) exists but is not in this image: UNVERIFIED, treat the draft's 8000 as not part of this image. |

## 2. Target layout

```
apps/drawio/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
  defaults/PreConfig.js.tmpl   # optional, only if CSP/PreConfig templating is kept
```
No `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`ghcr.io/trueforge-org/java11:<tag>@<digest>`: java11 exists in `apps/java11`, but its Dockerfile `FROM` is `ubuntu:26.4@sha256:19cb...`, and the `java11` image tag/digest must be taken from an existing consumer (`grep -l java11 apps/*/Dockerfile`); none of the sampled apps use it, so UNVERIFIED. `apps/java11/docker-bake.hcl` shows VERSION `11.0.29+7` (Temurin JRE). Tomcat 9 supports Java 8+, so JRE 11 is enough. Closest siblings: `apps/nzbhydra2` and `apps/airsonic-advanced` (Java apps from a base).

## 4. Dockerfile

1. `FROM` the java11 image (copy the tag and digest used by `apps/java11` bake output at port time).
2. `ARG VERSION`, `ARG TOMCAT_VERSION`; `USER root`; `apt-get install -y --no-install-recommends unzip` only if not already present (curl exists in base, `nzbhydra2` also installs only `unzip`).
3. Download Tomcat `apache-tomcat-${TOMCAT_VERSION}.tar.gz` and verify with the `.sha512` file; extract to `/app/tomcat` (strip components 1); delete `webapps/*`.
4. Download `draw.war` from `v${VERSION}`; `unzip` into `/app/tomcat/webapps/draw` (no checksum available, pinned by tag).
5. Make Tomcat read-only at runtime: set `CATALINA_BASE=/tmp/tomcat` (conf, logs, temp, work created by start.sh), keep `CATALINA_HOME=/app/tomcat`. Pre-edit `server.xml` at build into `/app/tomcat/conf-template/server.xml` (root Context with docBase `/app/tomcat/webapps/draw`, as upstream does with xmlstarlet; use `sed` or a template in `defaults/` to avoid installing xmlstarlet).
6. Licenses: Tomcat `LICENSE` and `NOTICE`, draw.io `LICENSE` (from the tag) to `/usr/share/licenses/drawio/`.
7. `ENV HOME=/config CATALINA_HOME=/app/tomcat CATALINA_TMPDIR=/tmp`; `COPY --chmod=0755 . /`; `EXPOSE 8080`; `VOLUME /config`; `USER apps`.
Certbot, Let's Encrypt and the 8443 TLS connector are not carried over (needs root/writable `/etc`): see 10.

## 5. docker-bake.hcl

`APP=drawio`, `VERSION=32.7.4`,
```hcl
// renovate: datasource=github-releases depName=jgraph/drawio versioning=semver extractVersion=^v(?<version>.+)$
```
(`extractVersion` strips the `v` prefix; the Dockerfile adds `v` back in the download URL), `LICENSE=Apache-2.0`, `SOURCE=https://github.com/jgraph/drawio`. Add `TOMCAT_VERSION` variable with its own renovate comment (datasource UNVERIFIED) and pass it in `args`. Four standard targets and `default` group; run `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/jgraph/drawio"
ports:
  - port: 8080
    protocol: tcp
    required: true
env:
  - {name: DRAWIO_CSP_HEADER, default: "", required: false}
  - {name: DRAWIO_GITLAB_ID, default: "", required: false}
  - {name: DRAWIO_GITLAB_URL, default: "", required: false}
  - {name: TZ, default: "Etc/UTC", required: false}
volumes:
  - path: /config
    required: true
dependencies: []
```
`DRAWIO_CSP_HEADER`, `DRAWIO_GITLAB_ID`, `DRAWIO_GITLAB_URL` verified in the upstream entrypoint. Add other `DRAWIO_*` only after reading the rest of that script (UNVERIFIED). Port 8000 is not listed since nothing opens it.

## 7. start.sh

- Build the runtime `CATALINA_BASE` in `/tmp/tomcat`: `mkdir -p conf logs temp work webapps`; copy `/app/tomcat/conf/*` and the prepared `server.xml` there on each start.
- Generate `PreConfig.js` (CSP, GitLab settings) into `/tmp/tomcat/preconfig/` and serve it by overlaying: because the webapp dir is read-only, either copy the unpacked `draw` dir to `/tmp/tomcat/webapps/draw` at start (slower, a few tens of MB, UNVERIFIED size) or only do so when a `DRAWIO_*` variable is set. Env values go in the file with escaping for quotes; do not put them on a command line.
- Bind all interfaces (Tomcat connector has no address attribute by default; verify with `ss`).
- `exec /app/tomcat/bin/catalina.sh run` with `CATALINA_BASE=/tmp/tomcat`; `JAVA_OPTS` may carry `-Xmx` defaults like nzbhydra2 (`-Xmx256M`, UNVERIFIED suitability).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
timeoutSeconds: 120
http:
  - port: '8080'
    path: /
filePaths:
  - /app/tomcat/webapps/draw/index.html
  - /usr/share/licenses/drawio/LICENSE
```
`timeoutSeconds` value is a guess (nzbhydra2 sibling sets none; `apps/wireguard` unchecked). One `http` probe covers the 8080 port. Test runs with no env, so the PreConfig path with env is run manually.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `$CATALINA_HOME/conf/server.xml` (xmlstarlet at build, entrypoint at run) | prepared at build; runtime copy in `/tmp/tomcat/conf` |
| `$CATALINA_HOME/webapps/draw/js/PreConfig.js` (entrypoint) | `/tmp/tomcat/webapps/draw/js/` copy when env set |
| `$CATALINA_HOME/{logs,temp,work}` | `$CATALINA_BASE` under `/tmp/tomcat` |
| Keystore for 8443 / certbot (`/etc/letsencrypt`) | not supported; optional keystore in `/config/ssl` (UNVERIFIED) |
| user home | `HOME=/config` |

Draft expects UID 0, writable rootfs, no persistence. Reconciliation: UID `apps` (568), read-only rootfs; drawio itself holds no server state (diagrams are client side), so `/config` is only for optional config/keystore. The upstream's own non-root story (UID 1001, GID 0) is replaced by `apps`.

## 10. Risks, caveats and open questions

- The draft's "export server on 8000 with Chromium" is not in the upstream `jgraph/drawio` image (UNVERIFIED but not present in the Dockerfile); drop it, or make it a separate app (`jgraph/draw-image-export2`), out of scope.
- No checksum for `draw.war`; supply chain trust is the tag only.
- The draw.io war in jgraph's image is built from source with ant; the release asset `draw.war` is assumed equivalent (UNVERIFIED).
- Unpacking `draw` into `/tmp` for PreConfig adds start-up time and memory on tmpfs.
- TLS/Let's Encrypt support of the upstream image is dropped.
- Base: java11 image digest must be copied from a real sibling; java 11 is EOL for most vendors but Temurin 11 is still patched.

## 11. Build and test steps

```sh
cd apps/drawio
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name drawio-probe --read-only --tmpfs /tmp \
  -v drawio-probe-config:/config drawio:32.7.4
docker logs -f drawio-probe
docker rm -f drawio-probe; docker volume rm drawio-probe-config
forgetool containers test --image drawio:32.7.4 --config ./apps/drawio/container-test.yaml
```
Expected readiness: Tomcat log `Server startup in [N] milliseconds` (standard Tomcat line) and a 200 on `/`. Repeat with `-e DRAWIO_CSP_HEADER="..."` manually.

## 12. PR checklist

- Branch `feat/add-drawio`, commit `feat(drawio): add new container`, PR template filled, only applicable boxes checked.
- Notes: `🤖 This PR is AI generated.`
- CLA: tell the user, https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- Untested: build, Tomcat base layout, PreConfig overlay, arm64, java11 base reference.
