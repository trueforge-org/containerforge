# xteve — implementation plan
> Source: ./draft.md · Target: apps/xteve/ · Difficulty: hard · Role (main/sidecar): main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value | Source |
| --- | --- | --- |
| Latest version | 2.2.0.0200 (project info.json). The chart tag is `v2.2.0.200` (draft). Release date: UNVERIFIED. | https://github.com/xteve-project/xTeVe-Downloads/blob/master/info.json |
| renovate | `xteve-project/xTeVe-Downloads` has no GitHub releases and no tags (API returns none), so a `github-releases` annotation cannot track it. Version source is `info.json` (`2.2.0.0200`); a custom renovate datasource is needed, UNVERIFIED. | derived |
| License | MIT, Copyright (c) 2019 marmei@xteve-project | https://raw.githubusercontent.com/xteve-project/xTeVe/master/LICENSE |
| Source | https://github.com/xteve-project/xTeVe (draft says archived; the GitHub API for `xteve-project/xTeVe` returns `archived: false`, so the draft claim is not confirmed) | draft |
| amd64 asset | `xteve_linux_amd64.zip` | https://github.com/xteve-project/xTeVe-Downloads (asset listing) |
| arm64 asset | `xteve_linux_arm64.zip` | https://github.com/xteve-project/xTeVe-Downloads (asset listing) |
| Download URLs | https://github.com/xteve-project/xTeVe-Downloads/raw/master/xteve_linux_amd64.zip and `.../xteve_linux_arm64.zip`. The raw URLs were not fetched; verify with a HEAD request at build time. | draft + listing |
| Checksum | None published. UNVERIFIED. | listing shows only info.json |
| Upstream Dockerfile | None found for the image `ghcr.io/k8s-at-home/xteve` (draft). | draft |
| Env vars | UNVERIFIED: none confirmed on fetched pages. Configuration is via web UI; docs at https://github.com/xteve-project/xTeVe-Documentation/blob/master/en/configuration.md (not fetched). | — |
| Ports | 34400/http default: UNVERIFIED (not found in README). | — |
| Config path | UNVERIFIED for the zip build (README points to external docs). | — |
| Dependencies | none | draft |

## 2. Target layout

- `Dockerfile`, `docker-bake.hcl`, `settings.yaml`, `container-test.yaml`, `start.sh`: required.
- `defaults/`: only if a default config is needed (decide after the config path is verified).
- No `etc/`, `scripts/`, `health/` unless required.
- `DOWNSTREAM_CHANGES.md`: not needed.
- Never use `root/`.

## 3. Base image

- `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`.
- Closest sibling: `apps/adguardhome-sync` (prebuilt Go binary archive extracted into `/app`, `USER apps`, `COPY --chmod=0755 . /`).
- Reason: prebuilt Go binary, no runtime packages needed.

## 4. Dockerfile

1. `ARG VERSION=2.2.0.200` (match bake; the zip is named without the version, so VERSION is only used for the tag).
2. `ARG TARGETARCH`, `USER root`.
3. Download: `curl -fsSL -o /tmp/xteve.zip "https://github.com/xteve-project/xTeVe-Downloads/raw/master/xteve_linux_${TARGETARCH}.zip"`. Note: the unpinned `master` URL is a risk. Record the byte size and SHA-256 at build time and verify on rebuild (no published checksum; state this in the PR).
4. `unzip` is already installed in `apps/ubuntu/Dockerfile`, so do not add it.
5. `unzip -o /tmp/xteve.zip -d /app` then `chmod 0755 /app/xteve`; `rm /tmp/xteve.zip`.
6. Licence: `install -Dm644` of the MIT LICENSE from the upstream repo into `/usr/share/licenses/xteve/LICENSE` (fetch the file during the build).
7. `ENV HOME=/config`, `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 34400` (UNVERIFIED), `VOLUME /config`.

## 5. docker-bake.hcl

- `APP = "xteve"`.
- `VERSION` with renovate annotation (see section 1 caveat), default `"2.2.0.200"` (tag form matching the chart).
- `LICENSE = "MIT"`.
- `SOURCE = "https://github.com/xteve-project/xTeVe"`.
- Standard targets and default group. Validate with `docker buildx bake --print`.

## 6. settings.yaml

- Schema header, `schema_version: 1`, `upstream_env_url: "https://github.com/xteve-project/xTeVe"`.
- `ports`: `- port: 34400, protocol: tcp, required: true` (UNVERIFIED port; confirm by running the binary and checking the listen socket before merging).
- `env`: none confirmed. Do not invent variables. Add only after they are verified.
- `volumes`: `- path: /config, required: true`.
- `dependencies`: none.

## 7. start.sh

- Shebang `#!/usr/bin/env bash`.
- Seed nothing yet (config path UNVERIFIED).
- Run the binary from `/config` working directory if xTeVe writes its config relative to CWD: `cd /config && exec /app/xteve` (UNVERIFIED: test with empty `/config`).
- If xTeVe writes to CWD, `/config` is the persistence path and `/tmp` is for scratch; never write to `/app`.
- Bind address: check listen address with `ss -ltn` (UNVERIFIED that it binds 0.0.0.0).

## 8. container-test.yaml

- Schema header from the sibling.
- `tcp: - port: '34400'` (match settings.yaml).
- `timeoutSeconds`: from a sibling Go app on ubuntu.
- `filePaths`: `/app/xteve` existence and executable check.
- Test runs with no env vars; xTeVe's configuration is done in the web UI, so the default path is the tested path.

## 9. Rootless and read-only-rootfs adaptations

- Chart expectations (draft): non-root yes (runAsUser 568 common default), read-only no (chart sets `readOnlyRootFilesystem false`), privileged no, no extra persistence.
- Target: non-root yes (`USER apps`), read-only yes (no writes to `/app`, state in `/config`, scratch in `/tmp`).
- The draft's "state to /tmp" suggestion conflicts with the rule that persistent state goes to `/config`. Choose `/config` for user config and playlists; `/tmp` only for scratch. Confirm by reading the upstream file paths after the first run.

## 10. Risks, caveats and open questions

- Upstream is archived (draft). Expect no fixes; `master`-branch downloads may change without a version change. Pin by recording the SHA-256 at build time.
- No checksum published; download integrity is UNVERIFIED.
- Asset URLs use the `master` branch of a downloads repo; a rename or removal would break the build.
- Ports, env vars, config path all UNVERIFIED. Blocker for `settings.yaml` completeness until verified by running the binary.
- IPTV source configuration is manual (web UI). The container test does not exercise it.
- Version format: the chart uses `v2.2.0.200`; info.json says `2.2.0.0200`. Pick one tag form and state the mapping in the PR.
- No blocker for build; blocker for full functional verification (`settings.yaml` ports/env unknown).

## 11. Build and test steps

From `apps/xteve`:
1. `docker buildx bake --print`.
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`.
3. `docker run --rm -d --name xteve-probe --read-only --tmpfs /tmp -v xteve-probe-config:/config xteve:2.2.0.200`.
4. `docker logs -f xteve-probe`. Expected readiness: UNVERIFIED (take the first real startup line from the run and record it).
5. `docker rm -f xteve-probe; docker volume rm xteve-probe-config`.
6. `forgetool containers test --image xteve:2.2.0.200 --config ./container-test.yaml`.
7. Round limit 10.

## 12. PR checklist

- Branch `feat/add-xteve`; commit and title `feat(xteve): add new container`.
- Notes: `🤖 This PR is AI generated.`
- CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign; `license/cla` shows status). Tell the user.
- PR template at `.github/PULL_REQUEST_TEMPLATE.md`; check only applicable boxes.
- State what was not tested: ports, env and config path if unverified; arm64 runtime; checksum (none upstream).
