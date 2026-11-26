# Context: arksurvivalevolved

Fetched 2026-11-26. Summaries of every web source referenced by `draft.md` and `plan.md`.

## Source URL -> file

| Source URL | File |
| --- | --- |
| https://github.com/arkmanager/ark-server-tools | github-arkmanager-ark-server-tools.md |
| https://raw.githubusercontent.com/arkmanager/ark-server-tools/v1.6.69/LICENSE | github-arkmanager-ark-server-tools.md |
| https://raw.githubusercontent.com/arkmanager/ark-server-tools/v1.6.69/tools/install.sh | github-arkmanager-ark-server-tools.md |
| https://raw.githubusercontent.com/arkmanager/ark-server-tools/v1.6.69/tools/arkmanager.cfg | github-arkmanager-ark-server-tools.md |
| https://raw.githubusercontent.com/arkmanager/ark-server-tools/v1.6.69/tools/arkmanager | github-arkmanager-ark-server-tools.md (partial) |
| https://github.com/arkmanager/ark-server-tools/releases | github-arkmanager-ark-server-tools.md |
| https://github.com/arkmanager/ark-server-tools/wiki | github-arkmanager-ark-server-tools-wiki.md |
| https://github.com/SickHub/arkserver/blob/394fd7aa4f6321e5665f9dbc7d1ff4600aa6386f/Dockerfile (fetched as raw) | github-sickhub-arkserver.md |
| https://raw.githubusercontent.com/SickHub/arkserver/394fd7aa4f6321e5665f9dbc7d1ff4600aa6386f/scripts/run.sh | github-sickhub-arkserver.md |
| https://hub.docker.com/r/drpsychick/arkserver | dockerhub-drpsychick-arkserver.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/arksurvivalevolved | truecharts-arksurvivalevolved.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/arksurvivalevolved/values.yaml | truecharts-arksurvivalevolved.md |
| https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz (archive, recorded only; from shared INDEX) | valve-steamcmd.md (shared copy) |
| Named reference: SteamCMD (no fetchable page; shared INDEX) | valve-steamcmd.md (shared copy) |
| Named reference: "ich777-style" steamcmd game-server pattern (shared INDEX) | ich777-docker-steamcmd-server.md (shared copy) |

## Skipped

- https://cla-assistant.io/trueforge-org/containerforge: CLA link.
- https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json: forgetool schema URL.
- https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu and `.../apps/steamcmd`: containerforge `apps/<base>` links.
- ghcr.io/trueforge-org/ubuntu, ghcr.io/trueforge-org/steamcmd (and the `<tag>@sha256:<digest>` placeholders): image references.
- docker.io/drpsychick/arkserver:latest: image reference (Docker Hub page fetched).
- https://github.com/arkmanager/ark-server-tools/archive/refs/tags/v1.6.69.tar.gz: archive download, not fetched; the tag is the source (plan.md section 1).
- https://github.com/arkmanager/ark-server-tools.git: git clone URL, not a web page (the tag is cloned in the Dockerfile plan).
- https://git.io/arkmanager (in SickHub Dockerfile only): short redirect for the upstream installer, not referenced by the draft or plan.

## Fetch failures / partial

- https://raw.githubusercontent.com/arkmanager/ark-server-tools/master/README.md: HTTP 404.
- https://raw.githubusercontent.com/arkmanager/ark-server-tools/v1.6.69/README.md: HTTP 404. No README content obtained.
- https://raw.githubusercontent.com/arkmanager/ark-server-tools/v1.6.69/tools/arkmanager: the fetched text stopped at about 100000 characters; the `--version` handler and instance loader were not in view.
- https://github.com/arkmanager/ark-server-tools/releases: loaded, but asset names did not render ("Assets 2").
- https://github.com/arkmanager/ark-server-tools/wiki: low content (4 pages, last edited 2017).
- SickHub `scripts/run.sh`: the fetch returned a structured summary, not the verbatim script.

## plan.md corrections

No in-place edits made. Checked against the sources:

- Confirmed (no edit): LICENSE is MIT, Copyright Fez Vrasta 2015 (plan.md section 1 said it was confirmed only by web search; raw LICENSE now fetched).
- Confirmed (no edit): `install.sh` takes a user (`<user>` or `--me`), installs to `/usr/local/bin` and `/etc/arkmanager` by default, installs no sudoers or cron entry, and needs `--install-service` for a service. Plan.md section 4 step 3 still says the arguments are "UNVERIFIED (not fetched)"; that is now stale, but not a factual error, so it was left as is.
- Confirmed (no edit): config lookup is `/etc/arkmanager/arkmanager.cfg` (global) then `${HOME}/.arkmanager.cfg` (user, overrides global). Plan.md section 7 step 4 is consistent.
- Confirmed (no edit): arkmanager runtime deps `lsof` and `perl` (plus `runuser`, `getent`), matching the plan's apt list.
- Confirmed (no edit): SickHub uses `am_ark_Port=7778`, `am_ark_RCONPort=32330`, `am_ark_ServerAdminPassword` default (not to copy), `EXPOSE 8080`, and the same "`arkmanager start --no-background --verbose` in a subshell, then wait" flow plan.md describes.

Unverified (left as is):

- plan.md section 8: `arkmanager --version` prints `Version: ...` and exits 0. The format and exit code were not in the fetched part of `tools/arkmanager`.
- plan.md section 4 and 10: whether an instance config is required (`instance.cfg`/`main.cfg`); the instance loader was truncated.
- plan.md section 1: RCON default 27020 (the chart uses 27020; ARK docs were not fetched).
- plan.md section 1: `arkmanager` v1.6.69 is the release with 5 commits on master since (not checked).
- plan.md section 3: `ghcr.io/trueforge-org/steamcmd` tag and digest (not checked).
- plan.md section 4: whether `libc6-i386`, `bzip2`, `perl-modules`, `lsof`, `rsync` are the right Ubuntu 26.04 package names (not checked).
