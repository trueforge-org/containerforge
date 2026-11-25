# jenkins — implementation plan
> Source: ./draft.md · Target: apps/jenkins/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | `2.544`, the draft pin, which the chart uses as `jenkins/jenkins:2.544-jdk17` (Docker Hub last_updated 2026-02-05). UNVERIFIED: the latest LTS line. The GitHub "latest" release is the weekly `jenkins-2.592` (year not shown on the page). The LTS update-center JSON was not fetched. |
| Renovate | Proposed `datasource=github-releases depName=jenkinsci/jenkins versioning=loose`. UNVERIFIED: the repo renovate config was not checked, and `loose` is chosen because Jenkins versions are two-part (`2.544`). |
| License | MIT (https://raw.githubusercontent.com/jenkinsci/jenkins/master/LICENSE.txt). The release page did not confirm it, so treat as MIT. |
| Source URL | https://github.com/jenkinsci/jenkins |
| Download | `https://get.jenkins.io/war/2.544/jenkins.war` (redirects to a mirror). The draft's `updates.jenkins.io` URL was not fetched directly. The WAR is arch-neutral. Java 17 is the runtime, per architecture. |
| Checksum source | `https://get.jenkins.io/war/2.544/jenkins.war.sha256` (redirect). The value `58d2c25c42859d0423329221629c9d4f99e68d68cb50d7c61f4474c27938a973` was read from `https://get.jenkins.io/war/2.544/jenkins.war.sha256` on 2026-11-25 and matches the earlier mirror value. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/jenkinsci/docker/2.544/debian/Dockerfile. Base `debian:trixie-20251117-slim`. Two stages: `jlink` builds a trimmed JRE, the controller copies it to `/opt/java/openjdk`. Downloads the WAR with `curl -fsSL`, then `sha256sum -c --strict`. `ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/jenkins.sh"]`. `USER jenkins` (uid/gid 1000). |
| Upstream WAR_SHA | The Dockerfile hard-codes `fcf13a8ebbe69d678608cc4b3885ece7d7e697d6da4c3691025a06968ddef228`. It does NOT match the 2.544 mirror checksum above. UNVERIFIED which version it belongs to. Do not reuse it. |
| Upstream fallback | `ARG JENKINS_VERSION=${JENKINS_VERSION:-2.534}` is the upstream default, which differs from 2.544. Pass the version explicitly. |
| Port | 8080/tcp (web UI). 50000/tcp (agent JNLP, `JENKINS_SLAVE_AGENT_PORT=50000` in upstream `ENV`). |
| Env (real) | Upstream `ENV`: `JENKINS_HOME=/var/jenkins_home`, `REF=/usr/share/jenkins/ref`, `JENKINS_UC=https://updates.jenkins.io`, `JENKINS_UC_EXPERIMENTAL`, `JENKINS_INCREMENTALS_REPO_MIRROR`, `JENKINS_SLAVE_AGENT_PORT=50000`, `COPY_REFERENCE_FILE_LOG`, `JAVA_HOME=/opt/java/openjdk`, `LANG=C.UTF-8`. README (https://raw.githubusercontent.com/jenkinsci/docker/master/README.md) also names `JENKINS_UC_DOWNLOAD` and `JENKINS_PLUGIN_INFO`. |
| Data path (upstream) | `/var/jenkins_home` (`VOLUME`). Initial admin password at `$JENKINS_HOME/secrets/initialAdminPassword` (README). |
| Runs as | uid 1000 (`jenkins`) upstream. |
| Launch script | `/usr/local/bin/jenkins.sh` is not in the facts file. UNVERIFIED: its exact `java` flags. Read it before copying any flag. |

## 2. Target layout

- `apps/jenkins/Dockerfile`
- `apps/jenkins/docker-bake.hcl`
- `apps/jenkins/settings.yaml`
- `apps/jenkins/container-test.yaml`
- `apps/jenkins/start.sh`

No `defaults/`, `etc/` or `health/` are needed. Plugins install at runtime into `JENKINS_HOME`, so no reference plugin set is shipped (no `/usr/share/jenkins/ref`). No `root/`. No `DOWNSTREAM_CHANGES.md`, because jenkins is not a `FROM` base.

## 3. Base image

`FROM ghcr.io/trueforge-org/java17:17.0.16@sha256:74b81362a2cf4b7f6efb8eb67baf0d1090ce56b38fc9e7a0dc11333b35179e1a`

Fits because Jenkins 2.544 runs on Java 17 and the java17 sibling provides it on the ContainerForge Ubuntu base. The base also has `tini` and `curl`, so no extra apt packages are needed. Closest siblings: `apps/nzbhydra2` (Java war or jar with `/config` data) and `apps/airsonic-advanced` (war, `apps` user, `-Djava.io.tmpdir=/tmp`).

UNVERIFIED: whether the java17 JRE covers Jenkins. Upstream uses a `jlink` trimmed JRE, and its module list is not in the facts. Test on the run.

## 4. Dockerfile

1. `ARG VERSION` and `ARG WAR_SHA256` (both must match `docker-bake.hcl`), then `USER root`.
2. Set paths so Jenkins writes only to `/config` and `/tmp`:

```dockerfile
ENV JENKINS_HOME=/config \
    JENKINS_UC=https://updates.jenkins.io \
    HOME=/config
```

3. Download the WAR, verify its checksum, and fetch the license:

```dockerfile
RUN mkdir -p /app /usr/share/licenses/jenkins \
 && curl -fsSL -o /app/jenkins.war \
      "https://get.jenkins.io/war/${VERSION}/jenkins.war" \
 && echo "${WAR_SHA256}  /app/jenkins.war" | sha256sum -c --strict - \
 && curl -fsSL -o /usr/share/licenses/jenkins/LICENSE.txt \
      "https://raw.githubusercontent.com/jenkinsci/jenkins/master/LICENSE.txt" \
 && chown -R root:root /app && chmod -R 755 /app \
 && rm -rf /tmp/*
```

   The `master` branch URL for the LICENSE is used because the facts confirm only that branch. Pin it to a tag once the tag name is confirmed (UNVERIFIED).
4. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE 8080 50000
VOLUME /config
```

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "jenkins"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=jenkinsci/jenkins versioning=loose
  default = "2.544"
}

variable "WAR_SHA256" {
  // Not managed by renovate: update together with VERSION, from get.jenkins.io/war/<version>/jenkins.war.sha256
  default = "58d2c25c42859d0423329221629c9d4f99e68d68cb50d7c61f4474c27938a973"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/jenkinsci/jenkins"
}
```

Use the four standard targets and the default group copied from `apps/nzbhydra2`. `image` passes `args = { VERSION = "${VERSION}", WAR_SHA256 = "${WAR_SHA256}" }`. Check with `docker buildx bake --print`. Renovate cannot update `WAR_SHA256`, so every version bump needs a manual checksum update (section 10).

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/jenkinsci/jenkins"
ports:
  - port: 8080
    protocol: tcp
    required: false
  - port: 50000
    protocol: tcp
    required: false
env:
  - name: JENKINS_HOME
    default: "/config"
    required: false
  - name: JENKINS_UC
    default: "https://updates.jenkins.io"
    required: false
  - name: JAVA_OPTS
    default: ""
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```

- `JENKINS_HOME` and `JENKINS_UC` are set in the Dockerfile `ENV`, so the defaults here must match it.
- `JAVA_OPTS` is read by `start.sh` (proposed, since upstream reads it in `jenkins.sh`, which is UNVERIFIED).
- Port 50000 is listed because the agent port is exposed. It is only open if the agent port is set (section 7).
- `dependencies: []`: Jenkins uses no database. Plugins need outbound network at runtime.

## 7. start.sh

```bash
#!/usr/bin/env bash

mkdir -p /config

# shellcheck disable=SC2086
exec java \
    -Djava.io.tmpdir=/tmp \
    -Djenkins.model.Jenkins.slaveAgentPort="${JENKINS_SLAVE_AGENT_PORT:-50000}" \
    ${JAVA_OPTS} \
    -jar /app/jenkins.war \
    --httpPort=8080 \
    --httpListenAddress=0.0.0.0
```

- Idempotent. Jenkins creates its own layout in `JENKINS_HOME` on first start. No seeding, no writes to `/app`.
- `--httpListenAddress=0.0.0.0` is set explicitly so the port is reachable from other containers. Verify the default (UNVERIFIED).
- The agent port is set with a system property (UNVERIFIED). Upstream sets the env var `JENKINS_SLAVE_AGENT_PORT=50000`, and whether Jenkins reads it directly is UNVERIFIED. Confirm that TCP 50000 is listening after the start, or the `tcp` probe in section 8 will fail.
- `exec` keeps the JVM as PID 1, so signals reach Jenkins for a clean shutdown.
- `${JAVA_OPTS}` is unquoted on purpose, so several options split. Do not add `eval`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 240
tcp:
- port: '8080'
- port: '50000'
http:
- port: '8080'
  path: /login
filePaths:
- /app/jenkins.war
- /usr/share/licenses/jenkins/LICENSE.txt
```

- Both ports in `settings.yaml` have a `tcp` probe, as the coverage rule requires.
- The `http` path `/login` is UNVERIFIED (not in the facts). Confirm it returns a 200 on the run, or use the status the run shows.
- `timeoutSeconds: 240` is used by four sibling apps. Jenkins startup is slow on first run, so the default of 180 may be too short.
- No env var is needed to start. Plugins are not installed by the test, so no plugin code path is tested.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/var/jenkins_home` (`JENKINS_HOME`, `VOLUME`, PVC in the chart) | `JENKINS_HOME=/config` |
| `$JENKINS_HOME/secrets/initialAdminPassword` | Lands in `/config/secrets/`, persistent. |
| Plugin downloads from `JENKINS_UC` | Into `/config/plugins`, persistent. Needs network. |
| `/usr/share/jenkins/ref` (reference plugins and files) | Not used. No plugins are seeded. |
| Java temp and WAR extraction | `-Djava.io.tmpdir=/tmp`. Where Jenkins extracts the WAR on `--read-only` is UNVERIFIED, so check the logs on the run. |

- Upstream runs as uid 1000. This image runs as `apps` (568). The chart sets `runAsUser 1000` and `fsGroup 1000`. Reconcile in the chart later (not in this task): either run the chart as 568 or keep 1000 and set the owner of `/config`.
- Chart `readOnlyRootFilesystem` is the common default (true). This image writes only to `/config` and `/tmp`, so it is compatible with `--read-only --tmpfs /tmp`.
- Not privileged.
- Existing chart data at `/var/jenkins_home` must be copied to `/config` for existing users.

## 10. Risks, caveats and open questions

- Checksum: the `WAR_SHA` in upstream (`fcf13a…`) belongs to another version (upstream default is 2.534). The pinned value `58d2c2…` comes from get.jenkins.io for 2.544.
- Renovate cannot bump `WAR_SHA256`. Every version bump is a manual two-value change. Consider a renovate `customManager` in a follow-up, which is out of scope here.
- Version: 2.544 is the chart's pin, not confirmed as the LTS or latest stable line. Check the LTS update-center before choosing the final version (UNVERIFIED).
- JRE: upstream builds a `jlink` JRE. The java17 base is a full runtime (see section 3). Check that Jenkins starts and that the `jlink` module list is not needed (UNVERIFIED).
- Launch flags from `jenkins.sh` are not in the facts. Read the script before copying flags. The plan uses only the flags above.
- Agent port 50000: only matters for remote build agents. It must be set explicitly to be open (section 7).
- Plugins install from the internet at first setup, which is slow and needs network access (draft caveat).
- The setup wizard must be completed in the UI on first start (draft caveat). The initial admin password is in `/config/secrets/initialAdminPassword` and in the logs.
- Dependencies: none.
- arm64: upstream publishes `jenkins/jenkins:2.544-jdk17` for amd64 and arm64. This build's arm64 is not tested.
- Blockers: none confirmed beyond the JRE question.

## 11. Build and test steps

```sh
cd apps/jenkins
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name jenkins-probe --read-only --tmpfs /tmp \
  -v jenkins-probe-config:/config jenkins:2.544
docker logs -f jenkins-probe
forgetool containers test --image jenkins:2.544 --config ./apps/jenkins/container-test.yaml
docker rm -f jenkins-probe; docker volume rm jenkins-probe-config
```

- Expected readiness signal: Jenkins logs `Jenkins is fully up and running` (UNVERIFIED wording on this version), and the agent port 50000 is listening.
- Confirm `/config/secrets/initialAdminPassword` exists after the start, and that a restart keeps `/config`.
- Check that the port answers from outside the container (`-p 8080:8080`), not only on localhost.

## 12. PR checklist

- Branch `feat/add-jenkins`. Commit and PR title `feat(jenkins): add new container`. Target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections, and check only the boxes that apply.
- Notes section includes `🤖 This PR is AI generated.`
- CLA: a signed Contributor License Agreement is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it. The `license/cla` check shows status.
- Say in the PR what was not tested: the LTS choice, the `--read-only` run, the agent port, the arm64 build, and the `/login` HTTP probe.
- `docker buildx bake --print` passes; bake `VERSION` and `WAR_SHA256` equal the Dockerfile `ARG` values; no assertion was weakened.
