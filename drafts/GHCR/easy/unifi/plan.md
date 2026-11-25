# unifi — implementation plan
> Source: ./draft.md · Target: apps/unifi/ · Difficulty: medium (draft says easy; see section 10) · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | Chart image pins `ghcr.io/goofball222/unifi:10.6.109`. Vendor package for 10.6.109 answers HTTP 200 at https://dl.ui.com/unifi/10.6.109/unifi_sysvinit_all.deb (`application/vnd.debian.binary-package`). Size and checksum UNVERIFIED (HEAD only). Latest stable UniFi Network version UNVERIFIED: not fetched. |
| Renovate | UNVERIFIED: no vendor version feed was confirmed. Proposed: `datasource=docker depName=ghcr.io/goofball222/unifi versioning=loose` for the tag, to be checked when the version source is settled. |
| License | Application: proprietary Ubiquiti software (EULA UNVERIFIED). Upstream packaging repo `goofball222/unifi`: Apache-2.0, not archived, pushed 2026-11-23. Source: https://api.github.com/repos/goofball222/unifi |
| Source URL | https://ui.com/ (vendor, per draft). Packaging reference: https://github.com/jacobalberty/unifi-docker (MIT, not archived). |
| Download amd64 and arm64 | https://dl.ui.com/unifi/${VERSION}/unifi_sysvinit_all.deb (one `all` package, so the same file for both arches). |
| Checksum source | None published. Upstream Dockerfile installs with `dpkg --force-all -i` and does no checksum or signature check. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/goofball222/unifi/master/10.6/official/Dockerfile.debian (read through WebFetch). `FROM debian:trixie-slim`; packages incl. `openjdk-25-jre-headless` and `mongodb-org-server` (MongoDB 8.0 apt repo); user/group `unifi` created from PUID/PGID (999); `WORKDIR /usr/lib/unifi`; `ENTRYPOINT ["docker-entrypoint.sh"]`, `CMD ["unifi"]`; no `USER` instruction. |
| Java version | Upstream installs OpenJDK 25 (`openjdk-25-jre-headless`). The draft's default of java17 does not match. |
| Ports | From upstream EXPOSE: 3478/udp, 6789/tcp, 8080/tcp, 8443/tcp, 8843/tcp, 8880/tcp, 10001/udp. Matches the draft. |
| Volumes | Upstream VOLUME: `/usr/lib/unifi/cert`, `/usr/lib/unifi/data`, `/usr/lib/unifi/logs`. The draft also names `/usr/lib/unifi/olddata` and the chart uses it as a config key (UNVERIFIED for upstream). |
| Env vars | Upstream ENV: `BIND_PRIV=false`, `DEBUG=false`, `JVM_EXTRA_OPTS`, `JVM_INIT_HEAP_SIZE`, `JVM_MAX_HEAP_SIZE=1024M`, `PGID=999`, `PUID=999`, `RUN_CHOWN=true`, `RUNAS_UID0=false`. The entrypoint script is not in the fetched content, so which of these it reads is UNVERIFIED beyond the names. |
| Health | Upstream HEALTHCHECK: `/usr/local/bin/docker-healthcheck.sh` with `--start-period=2m`. |
| Sibling apps | `apps/java17`, `apps/java25`(exists in brief list), `apps/mongodb` (FROM ubuntu 26.04, renovate `github-tags mongodb/mongo`), `apps/unifi-network-application` (wraps linuxserver `unifi-network-application`, a different image). No `apps/unifi`. |

## 2. Target layout

- `apps/unifi/Dockerfile`
- `apps/unifi/docker-bake.hcl`
- `apps/unifi/settings.yaml`
- `apps/unifi/container-test.yaml`
- `apps/unifi/start.sh` (seeds `/config`, points the UniFi data, logs and cert paths at `/config`, and `exec`s the controller)
- `apps/unifi/defaults/` only if a default `system.properties` or similar seed is needed (decide in step 4; reason: first start without a config).

No `root/`. `DOWNSTREAM_CHANGES.md` not needed (not a FROM base).

## 3. Base image

`FROM ghcr.io/trueforge-org/java25:25.0.1@sha256:22a0f8a73c79e2f733c7513aefceef24ab8a213fd35af0ab1946996efc21636d`

Reason: upstream runs on OpenJDK 25, so `java25` matches the runtime. The draft's `java17` default would run an older JVM than the vendor package was built for and is not recommended. Confirm that UniFi 10.6 runs on JDK 25 in step 11 (UNVERIFIED on the vendor side). Closest sibling for the package-install pattern: `apps/mongodb` (build and install on ubuntu) and `apps/java25` as the runtime.

If the team keeps `java17`, the plan changes: `FROM ghcr.io/trueforge-org/java17:17.0.16@sha256:74b81362a2cf4b7f6efb8eb67baf0d1090ce56b38fc9e7a0dc11333b35179e1a`, with a documented JDK 17 incompatibility risk (section 10).

## 4. Dockerfile

1. `ARG VERSION` (matches bake default), `ARG TARGETARCH`, `USER root` for installs only.
2. Install the `mongodb-org-server` in this app or depend on `apps/mongodb`? Decision: depend on `apps/mongodb` (the draft's intent) and do not install mongo here. Upstream also installs `python3`, `gosu`, `procps`, `curl`, `libcap2-bin`, `tzdata`, `ca-certificates-java`; check the base for each and install only what is missing, pinned against `VERSION` where from apt.
3. Install the vendor package without running `dpkg -i` (its postinst creates users and writes into `/usr/lib/unifi`):

```dockerfile
RUN set -eux; \
    curl -fsSL -o /tmp/unifi.deb "https://dl.ui.com/unifi/${VERSION}/unifi_sysvinit_all.deb"; \
    mkdir -p /app/unifi; \
    dpkg-deb -x /tmp/unifi.deb /app/unifi; \
    rm -f /tmp/unifi.deb
```

   This extraction path is a proposal and is UNVERIFIED that the controller starts from an extracted tree with no postinst. Test it in step 11. Also check the extracted layout: the package contains `/usr/lib/unifi`, which must map to `/app/unifi/usr/lib/unifi`, and paths in `system.properties` need to be rewritten to `/config` (section 7).
4. License: install the Ubiquiti EULA or notices from the package if they exist; otherwise record `UNVERIFIED` in the PR. Do not invent a license file.
5. `ENV` for the app: `JVM_MAX_HEAP_SIZE=1024M` (upstream default), `HOME=/tmp`. Do not copy the PUID/PGID/RUNAS_UID0 variables, since the app runs as `apps` (see section 9).
6. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE 3478/udp 6789/tcp 8080/tcp 8443/tcp 8843/tcp 8880/tcp 10001/udp
VOLUME /config
WORKDIR /app/unifi/usr/lib/unifi
```

## 5. docker-bake.hcl

Same layout as `apps/steamcmd/docker-bake.hcl` (four standard targets and the default group).

```hcl
variable "APP" {
  default = "unifi"
}

variable "VERSION" {
  // renovate: datasource=UNVERIFIED depName=unifi versioning=loose
  default = "10.6.109"
}

variable "LICENSE" {
  default = "LicenseRef-Ubiquiti-EULA"
}

variable "SOURCE" {
  default = "https://ui.com/"
}
```

- The renovate line is a placeholder: the vendor version feed is not confirmed. Replace it with a verified datasource before merge (UNVERIFIED).
- `LICENSE` must match the software's license; `LicenseRef-Ubiquiti-EULA` is a proposal, not verified.
- Validate with `docker buildx bake --print` in `apps/unifi/`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://ui.com/"
ports:
  - port: 8443
    protocol: tcp
    required: true
  - port: 8080
    protocol: tcp
    required: true
  - port: 8843
    protocol: tcp
    required: false
  - port: 8880
    protocol: tcp
    required: false
  - port: 6789
    protocol: tcp
    required: false
  - port: 3478
    protocol: udp
    required: false
  - port: 10001
    protocol: udp
    required: false
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
  - name: JVM_MAX_HEAP_SIZE
    default: "1024M"
    required: false
  - name: JVM_INIT_HEAP_SIZE
    default: ""
    required: false
  - name: JVM_EXTRA_OPTS
    default: ""
    required: false
volumes:
  - path: /config
    required: true
dependencies:
  - mongodb
```

- `dependencies`: `mongodb` is a hard dependency (the controller uses MongoDB). Confirm the database wiring (env names and host/port) from upstream entrypoint or the chart; the entrypoint script was not fetched (UNVERIFIED). Do not add `unifi-network-application`: it is a different image (linuxserver wrapper) and the draft's reuse of it is not supported by the upstream packaging.
- `env`: the JVM variables are confirmed as upstream ENV names. Do not list PUID, PGID or RUNAS_UID0 (see section 9).
- Ports: 8080, 8443 and the other ports come from upstream EXPOSE; required flags are a proposal.

## 7. start.sh

- Idempotent: create `/config/data`, `/config/logs`, `/config/cert` when missing; seed `system.properties` only when missing; never write to `/app`.
- Remap: the upstream paths `/usr/lib/unifi/data`, `/usr/lib/unifi/logs`, `/usr/lib/unifi/cert` become symlinks to `/config/...`, or the controller is started with a data directory option (UNVERIFIED which mechanism the controller supports). `WORKDIR` is under `/app`, so no writes may happen there.
- Export the JVM variables from env with the defaults from `settings.yaml`.
- Database: apply the mongo connection from env on every start (secrets from env only, no secrets in files or argv).
- Bind: the controller must listen on `0.0.0.0` for the TCP ports (check `system.properties` `unifi.http.address` or equivalent, UNVERIFIED).
- End with `exec` to the controller, as upstream `CMD ["unifi"]` implies (the upstream launcher name `unifi` is UNVERIFIED on the extracted tree).

## 8. container-test.yaml

- Schema header from `apps/steamcmd/container-test.yaml`.
- `tcp` probes for every TCP port in `settings.yaml`: 8443, 8080, 8843, 8880, 6789. UDP ports (3478, 10001) cannot be probed with a `tcp` check; they need a schema-supported UDP check or a narrower assertion (UNVERIFIED that forgetool supports UDP).
- `timeoutSeconds`: the controller start is slow (upstream HEALTHCHECK `--start-period=2m`), so use a value taken from a Java sibling (`apps/java25` or `apps/nzbhydra2`), not the default.
- `filePaths`: `/app/unifi/usr/lib/unifi/lib/ace.jar` (UNVERIFIED path), `/start.sh`.
- DB dependency: the app has a hard dependency on `mongodb`, and the controller fails without it. The narrowing exception in `build-test-protocol` applies only if all three criteria hold. Narrowed assertions must carry the comment `# narrowed: requires external mongodb; full functional test not feasible in single-container suite`. Confirm in step 11 that the three criteria hold before narrowing.

## 9. Rootless and read-only-rootfs adaptations

- Upstream runs as root by default (no `USER`, entrypoint remaps `unifi` with `PUID`/`PGID` through `gosu`). ContainerForge target is `USER apps`. The `PUID`/`PGID` mapping is not used; drop it.
- The controller writes to its data, logs and cert directories. Under `--read-only`, all three must point at `/config` (or `/tmp` for logs). Persistent state (data, cert) goes to `/config`; logs can go to `/tmp` or `/config/logs`, decided in step 11.
- Upstream security expectations from the draft (non-root no, read-only rootfs no) are not met as shipped. This plan targets non-root and read-only rootfs, and it is the main reason for the difficulty change.
- Extra persistence per the draft: `/usr/lib/unifi/olddata` maps to a config key. Keep it as `/config/olddata` if the controller uses it (UNVERIFIED).
- `hostNetwork`: not used upstream. Device discovery (10001/udp) and STUN (3478/udp) may not work in a bridged container (draft caveat).

## 10. Risks, caveats and open questions

- Difficulty: draft says easy. This plan says medium: a vendor .deb that is not verified to run from an extracted tree, a hard MongoDB dependency, and a root entrypoint that must be rewritten for `apps` user and read-only rootfs.
- Java: draft default `java17`; upstream uses OpenJDK 25. Plan uses `java25`. Confirm compatibility.
- Version source and renovate line are UNVERIFIED. Latest UniFi version not checked.
- Checksum: none published for the .deb. Pinning a hash ourselves is an open question.
- Licence and EULA: UNVERIFIED.
- Upstream ENV handling in the entrypoint: UNVERIFIED (script not fetched).
- arm64: the draft marks `yes*`. The package is `all` (Java), but the MongoDB dependency and the JRE's arm64 support are UNVERIFIED. `copy-from arm64` is `no` in the draft and is not confirmed. Build amd64 first.
- `copy-from amd64` in the draft points to `ghcr.io/goofball222/unifi:10.6.109`; this is not used (the app is built from the vendor package).
- Blocker candidates: UDP discovery ports in bridged networking; dependency wiring not in the draft's dependency list.

## 11. Build and test steps

From `apps/unifi/`:

1. `docker buildx bake --print`
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`
3. Check the extracted tree and the launcher: `docker run --rm --entrypoint sh unifi:10.6.109 -c 'ls /app/unifi/usr/lib/unifi'`
4. Start with a fresh `/config` volume and a MongoDB container on the same network (mongodb sibling image), using `--read-only --tmpfs /tmp`:
   `docker network create unifi-probe-net`
   `docker run --rm -d --name unifi-probe-db --network unifi-probe-net ghcr.io/trueforge-org/mongodb:<version>` (exact image tag from `apps/mongodb` bake; UNVERIFIED)
   `docker run --rm -d --name unifi-probe --network unifi-probe-net --read-only --tmpfs /tmp -v unifi-probe-config:/config -e <db env> unifi:10.6.109`
   `docker logs -f unifi-probe`
   Expected readiness: process still running; log line that the web service is listening on 8443 (exact text UNVERIFIED). No fatal errors or repeated stack traces.
5. Cleanup: `docker rm -f unifi-probe unifi-probe-db; docker volume rm unifi-probe-config; docker network rm unifi-probe-net`
6. `forgetool containers test --image unifi:10.6.109 --config ./apps/unifi/container-test.yaml`
7. arm64 is not built unless the amd64 build fails for an arm64-specific reason.

## 12. PR checklist

- Branch `feat/add-unifi`, commit `feat(unifi): add new container`.
- Use `.github/PULL_REQUEST_TEMPLATE.md`; check only the boxes that apply.
- Notes section: `🤖 This PR is AI generated.`
- CLA notice: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- State what is untested: the live controller, the MongoDB wiring, the UDP ports, arm64, and the extracted-package startup path unless verified in step 11.
- Document downstream impact only if this image is a FROM base (not expected).
