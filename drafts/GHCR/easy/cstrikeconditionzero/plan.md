# cstrikeconditionzero — implementation plan
> Source: ./draft.md · Target: apps/cstrikeconditionzero/ · Difficulty: easy · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value | Source |
| --- | --- | --- |
| Chart | cstrikeconditionzero. Values: `GAME_ID: 90 +app_set_config '90 mod dmc'` (line 40), `GAME_MOD: 90 mod czero` (line 41), `GAME_NAME: czero` (line 42), `GAME_PARAMS: -secure +maxplayers 32 +map as_oilrig` (line 43), `GAME_PORT: "27015"` (line 44) | https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/cstrikeconditionzero/values.yaml |
| Chart image today | `ghcr.io/ich777/steamcmd:cstrikeczero@sha256:18707ecd07b955187f556665ef65cf4847a300f9f972869b12882e2896fda44a` | same values.yaml, line 5 |
| Upstream wrapper | ich777/docker-steamcmd-server, same as cstrike1-6 (master, last push 2026-07-18, no SPDX license) | `gh api repos/ich777/docker-steamcmd-server` |
| Upstream Dockerfile | `FROM ich777/debian-baseimage:bullseye_amd64`, `lib32gcc-s1 lib32stdc++6 lib32z1`, ENTRYPOINT `/opt/scripts/start.sh` | https://raw.githubusercontent.com/ich777/docker-steamcmd-server/master/Dockerfile |
| Upstream start-server | `steamcmd +login anonymous +force_install_dir <SERVER_DIR> +app_update ${GAME_ID} [validate] +quit`, then `srcds_run` on master but `hlds_run -game ${GAME_NAME} ${GAME_PARAMS} -console +port ${GAME_PORT}` on the `cstrikeczero` branch (verified), which the chart image tag `cstrikeczero` uses | https://raw.githubusercontent.com/ich777/docker-steamcmd-server/cstrikeczero/scripts/start-server.sh |
| SteamCMD download | `http://media.steampowered.com/client/steamcmd_linux.tar.gz` (plain HTTP, no checksum) | start-server.sh |
| Ports | 27015/tcp (rcon), 27015/udp (game and query) | chart values.yaml lines 21-31 |
| Upstream write paths | `/serverdata/serverfiles`, `/serverdata/steamcmd`, `/serverdata/.steam/sdk32` | Dockerfile ENV, start-server.sh |
| License | Steam EULA for the game (`UNVERIFIED: not fetched`). Wrapper: none declared | GitHub API |
| arm64 | No. SteamCMD bootstrap is 32-bit x86 | apps/steamcmd/docker-bake.hcl (local, amd64 only) |
| Dependencies | None | draft |

**Chart values are not a clean app id.** `GAME_ID` in the chart is `90 +app_set_config '90 mod dmc'`, and `GAME_MOD` is `90 mod czero`. Upstream expands `${GAME_ID}` unquoted into `+app_update`, so the chart value would pass several steamcmd arguments. The `dmc` mod in the chart looks like a chart mistake. The plan uses app 90 with mod `czero` (the name in `GAME_NAME`). This is `UNVERIFIED` until a run confirms it, see section 10.

## 2. Target layout

Same as cstrike1-6: `Dockerfile`, `docker-bake.hcl`, `settings.yaml`, `container-test.yaml`, `start.sh`. No `defaults/`, `etc/`, `scripts/`, `health/`. `root/` is never used. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

- FROM: `ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`.
- Why: SteamCMD install as in `apps/steamcmd`. The `ghcr.io/trueforge-org/steamcmd` image is not used as FROM by any sibling.
- Closest sibling: `apps/steamcmd`.

## 4. Dockerfile

Same steps as cstrike1-6 (see that plan's section 4), with these differences:

- Replace the `GAME_NAME` and `GAME_PORT` defaults with `czero` and `27015`.
- `GAME_PARAMS` default: `-secure +maxplayers 32 +map as_oilrig`.
- The mod is set through start.sh (`+app_set_config 90 mod czero`), not through `GAME_ID`.
- Label the image with `org.opencontainers.image.source` from the bake file.
- `USER apps`, `COPY --chmod=0755 . /`, `ENTRYPOINT ["/start.sh"]`, `EXPOSE 27015/tcp 27015/udp`.
- Licensing: copy any steamcmd license text to `/usr/share/licenses/cstrikeconditionzero/` if present. Otherwise `UNVERIFIED`.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "cstrikeconditionzero"
}

variable "VERSION" {
  // renovate: datasource=deb depName=steamcmd registryUrl=https://archive.ubuntu.com/ubuntu
  default = "20180105-5build1"
}

variable "LICENSE" {
  default = "UNVERIFIED: Steam EULA; wrapper declares no SPDX"
}

variable "SOURCE" {
  default = "https://store.steampowered.com/search/?term=Counter-Strike+Condition+Zero"
}
```

- `SOURCE`: the store search page is the draft's source link. Prefer the Steam app page for app 90 if the team agrees, since it is the real download source.
- Targets as in cstrike1-6: `docker-metadata-action`, `image`, `image-local` (`${APP}:${VERSION}`), `image-all` with `linux/amd64` only, `group "default"`.
- Validate with `docker buildx bake --print`.

## 6. settings.yaml

Same shape as cstrike1-6 (`schema_version: 1`, `upstream_env_url`, tcp and udp 27015 as `required: true`, `TZ`, `STEAM_USERNAME`, `STEAM_PASSWORD`, `GAME_PARAMS` default `-secure +maxplayers 32 +map as_oilrig`, `GAME_PORT` default `27015`, `VALIDATE` default `false`, `/config` volume `required: true`). No `dependencies:` key.

Do not expose `GAME_ID` or `GAME_MOD` as env vars: they are fixed in start.sh (see section 7). The chart's dmc/czero mismatch must not carry over.

## 7. start.sh

Same as cstrike1-6 (`set -euo pipefail`, `HOME=/config`, `XDG_CACHE_HOME=/tmp`, seed `/config` only when missing, copy steamcmd from `/usr/local/share/steamcmd`, `+runscript` with a `/tmp` file for the login, `app_update 90` with `validate` when `VALIDATE=true`, copy `linux32/*` into `/config/.steam/sdk32` when missing, `exec ./hlds_run -game czero ${GAME_PARAMS} -console +port ${GAME_PORT}`).

Differences:

- Install the mod before updating: `+app_set_config 90 mod czero` before `+app_update 90`. This is the upstream chart's `GAME_MOD` value. Check the order against a real run (`UNVERIFIED`).
- Pass the game arguments as an array. Never `eval`.
- Use `GAME_NAME=czero` (fixed) for `-game`.
- Expected first-run log: steamcmd prints `Success! App '90' fully installed` (`UNVERIFIED` exact text), then hlds starts.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

filePaths:
  - /start.sh
  - /usr/local/share/steamcmd/steamcmd.sh
tcp:
  - port: '27015'
```

- Probe 27015 over tcp. UDP has no probe in the schema (`UNVERIFIED: forgetool udp support`).
- Expect a slow first start (Steam download of several GB). Set `timeoutSeconds` high, `UNVERIFIED`.
- No DB, so no narrowing.

## 9. Rootless and read-only-rootfs adaptations

Same mapping as cstrike1-6 (section 9 there):

- `/serverdata/serverfiles` to `/config/serverfiles`, `/serverdata/steamcmd` to `/config/steamcmd`, `/serverdata/.steam/sdk32` to `/config/.steam/sdk32`.
- Root UID remap removed; the image runs as `apps`.
- `TMPDIR` and `XDG_CACHE_HOME` on `/tmp`.
- `privileged` false. `readOnlyRootFilesystem` must work with `--read-only --tmpfs /tmp`.

Security expectation check (draft): the chart runs as UID 0 and has `readOnlyRootFilesystem: false`. The target changes both (apps and read-only). Confirm both still work for the mod.

## 10. Risks, caveats and open questions

10.1 Chart `GAME_ID` mismatch (`90 +app_set_config '90 mod dmc'`) vs `GAME_MOD` (`90 mod czero`). The plan uses `mod czero`. Confirm the mod name with the chart author or a run. `UNVERIFIED`.

10.2 Blockers: no arm64 (SteamCMD 32-bit). Requires Steam network access at first start.

10.3 Upstream status of this legacy game server is unclear (draft caveat). Steam update compatibility is not guaranteed.

10.4 Steam EULA and `LICENSE` value: not confirmed.

10.5 GSLT: needed for a public listing per the draft, `UNVERIFIED` on any fetched page. Add an optional `STEAM_GSLT` only if confirmed.

10.6 Same plain-HTTP steamcmd download as upstream is avoided by using the apt package.

## 11. Build and test steps

From `apps/cstrikeconditionzero/`:

1. `docker buildx bake --print` (exit 0).
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`.
3. Empty `/config` start:
   ```sh
   docker run --rm -d --name cstrikeconditionzero-probe --read-only --tmpfs /tmp \
     -v cstrikeconditionzero-probe-config:/config ${APP}:${VERSION}
   docker logs -f cstrikeconditionzero-probe
   ```
   Pass: container stays up, install completes, hlds reports it is listening on 27015 (`UNVERIFIED` exact text). Cleanup: `docker rm -f` and `docker volume rm`.
4. `forgetool containers test --image <image>:<version> --config ./apps/cstrikeconditionzero/container-test.yaml`.
5. Round limit 10.

## 12. PR checklist

- Branch `feat/add-cstrikeconditionzero`, commit and PR title `feat(cstrikeconditionzero): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`; check only applicable boxes.
- Notes: `🤖 This PR is AI generated.`
- Tell the user about the CLA at https://cla-assistant.io/trueforge-org/containerforge (only the user can sign it).
- State what was not tested (for example, the Steam download and the mod name if not confirmed). Do not check "Built container locally" unless it was built.
- Bake print passed; image-local built; empty `/config` start on read-only rootfs; assertions unchanged; scratch containers and volumes removed.
