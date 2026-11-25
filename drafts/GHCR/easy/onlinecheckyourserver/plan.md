# onlinecheckyourserver — implementation plan
> Source: ./draft.md · Target: apps/onlinecheckyourserver/ · Difficulty: easy · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | No releases or tags. Last commit on default branch `318fcf88d83106b4d70bd731e7bac03a4b66795c`, 2022-10-25 (https://api.github.com/repos/ich777/docker-online-check-pushover/commits?per_page=1). |
| Renovate | No release to track. Pin the commit sha; renovate `datasource=git-refs` with `currentValue=master`. |
| License | None declared (GitHub API returns no license). No license file found in the repo root listing. UNVERIFIED: do not set a permissive SPDX without a source; ask the user. |
| Source | https://github.com/ich777/docker-online-check-pushover |
| Upstream Dockerfile | https://raw.githubusercontent.com/ich777/docker-online-check-pushover/master/Dockerfile: `FROM ich777/debian-baseimage` (not ubuntu), `apt-get install iputils-ping`, `useradd -s /bin/bash $USER`, `chmod -R 777 /opt/scripts/`, `ADD /scripts/ /opt/scripts/`, `ENTRYPOINT ["/opt/scripts/start.sh"]`. No EXPOSE, no VOLUME, no USER. |
| Upstream start.sh | Runs as root: `usermod -u ${UID}`, `groupmod`, `usermod -g`, `umask ${UMASK}`, `chown -R ${UID}:${GID} ${DATA_DIR}`, then `su ${USER} -c /opt/scripts/start-server.sh`. UMASK and DATA_DIR are not set in the Dockerfile (UNVERIFIED defaults). |
| Upstream start-server.sh | Loop: `ping -c 1 -W ${PING_TIMEOUT} "${HOST}"`, sleep `${PING_INTERVAL}`. On failure: `wget` to https://api.pushover.net/1/messages.json with the token/title/message/priority, sleep `${PING_RETRY}`, retry. |
| Env vars | HOST (`google.com`), PING_INTERVAL (`300`), PING_TIMEOUT (`10`), PING_RETRY (`3600`), PUSHOVER_APP_TOKEN (empty), PUSHOVER_USER_TOKEN (empty), PUSHOVER_TITLE (`Online Check`), PUSHOVER_MESSAGE (`google.com is offline!`), PUSHOVER_PRIORITY (`0`, range -2 to 2 per README). Also UID (`99`), GID (`100`), USER (`onlinecheck`), DATA_PERM (`770`). Source: Dockerfile and README https://raw.githubusercontent.com/ich777/docker-online-check-pushover/master/README.md. |
| Ports | None. Confirmed: no listener. |
| Data paths | None written by upstream. |
| Dependencies | Outbound internet (ping target and api.pushover.net); a Pushover app token and user key (external). |
| Restart | README recommends `--restart=unless-stopped`. |
| arm64 | Upstream is arch-neutral (debian, apt, shell). Image arch list UNVERIFIED. |

## 2. Target layout

- `apps/onlinecheckyourserver/Dockerfile`
- `apps/onlinecheckyourserver/docker-bake.hcl`
- `apps/onlinecheckyourserver/settings.yaml`
- `apps/onlinecheckyourserver/container-test.yaml`
- `apps/onlinecheckyourserver/start.sh`
- `apps/onlinecheckyourserver/scripts/` only if the ping and wget scripts are copied in. `scripts/` is in `include/.dockerignore`'s allow-list, so put the scripts there, not in the app root.

No `defaults/`, `etc/` or `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`. The upstream base is `ich777/debian-baseimage`, but ContainerForge rule: `ubuntu` for generic userland, and this is a shell script. Closest sibling: `apps/adguardhome-sync` (ubuntu, simple start.sh).

## 4. Dockerfile

1. `ARG VERSION`, `USER root`.
2. `apt-get install --no-install-recommends iputils-ping wget`, check the base first and skip what it already has. Remove apt lists.
3. `COPY` the two scripts into `/app/online-check/` (not `/config`); `chmod 0755`.
4. `ENV HOST=google.com PING_INTERVAL=300 PING_TIMEOUT=10 PING_RETRY=3600 PUSHOVER_TITLE="Online Check" PUSHOVER_MESSAGE="google.com is offline!" PUSHOVER_PRIORITY=0 HOME=/config`.
5. `USER apps`, `COPY --chmod=0755 . /`, `VOLUME /config`. No EXPOSE.

## 5. docker-bake.hcl

- `APP` = `onlinecheckyourserver`; `VERSION` = `318fcf88d83106b4d70bd731e7bac03a4b66795c` with `// renovate: datasource=git-refs depName=https://github.com/ich777/docker-online-check-pushover currentValue=master`.
- `LICENSE`: UNVERIFIED (no source). Block the PR until the user confirms.
- `SOURCE` = `https://github.com/ich777/docker-online-check-pushover`.
- Standard four targets and default group. Validate with `docker buildx bake --print`.

## 6. settings.yaml

- Schema header and `schema_version: 1`; `upstream_env_url` = source URL.
- `ports`: none (no listener).
- `env`: HOST, PING_INTERVAL, PING_TIMEOUT, PING_RETRY, PUSHOVER_APP_TOKEN (`required: true`, no default; generated or handled by start.sh only as a check), PUSHOVER_USER_TOKEN (same), PUSHOVER_TITLE, PUSHOVER_MESSAGE, PUSHOVER_PRIORITY. Drop UID/GID/USER/DATA_PERM because the non-root image does not use them.
- `volumes`: `/config` (HOME only; the script writes nothing).
- `dependencies`: none.

## 7. start.sh

- Do not port upstream's `usermod`/`groupmod`/`chown` steps; the image runs as `apps`.
- Check required tokens; if empty, print a message and `sleep infinity` or exit non-zero (decide with the user; UNVERIFIED which is preferred).
- `exec /app/online-check/start-server.sh`, with the ping and wget loop unchanged.
- Quote variables in the wget `--post-data` string (upstream does not; special characters in messages can break the command).

## 8. container-test.yaml

- Schema header; no tcp or http probes (no ports).
- `timeoutSeconds` from `apps/adguardhome-sync` (UNVERIFIED value).
- `filePaths: [/app/online-check/start-server.sh]`.
- Empty tokens: the test runs with no env vars, so the path that calls Pushover is not exercised; add it to `filePaths` and run it manually per the protocol.

## 9. Rootless and read-only-rootfs adaptations

- Upstream `ping` needs raw-socket capability; as `apps` it may fail on ubuntu (UNVERIFIED). Test with `docker run --cap-add NET_RAW` if needed, and say so in the PR.
- Only `/tmp` and `/config` are writable. The script writes no files.
- The chart's `runAsUser 0` and `readOnlyRootFilesystem false` are not carried over.

## 10. Risks, caveats and open questions

- No license: blocks the PR until confirmed.
- Rolling upstream with no release: the pinned commit is from 2022 and may be stale.
- Needs `NET_RAW` for `ping` (UNVERIFIED).
- Needs an external Pushover account.
- Blockers: licence and version are unknown.

## 11. Build and test steps

```sh
cd apps/onlinecheckyourserver
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name onlinecheck-probe --read-only --tmpfs /tmp -v onlinecheck-probe-config:/config onlinecheckyourserver:318fcf88d83106b4d70bd731e7bac03a4b66795c
docker logs -f onlinecheck-probe
forgetool containers test --image onlinecheckyourserver:318fcf88d83106b4d70bd731e7bac03a4b66795c --config ./apps/onlinecheckyourserver/container-test.yaml
docker rm -f onlinecheck-probe; docker volume rm onlinecheck-probe-config
```

Expected readiness: the log shows `is reachable` lines from the ping loop (matches upstream message text).

## 12. PR checklist

- Branch `feat/add-onlinecheckyourserver`; commit `feat(onlinecheckyourserver): add new container`.
- PR template; `🤖 This PR is AI generated.` in Notes.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- Not tested: no build or run in this planning step. Licence must be confirmed before the PR.
