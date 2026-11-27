# Valve SteamCMD

## Source URL(s) + fetch date
- https://developer.valvesoftware.com/wiki/SteamCMD (403 Forbidden to WebFetch)
- https://developer.valvesoftware.com/w/index.php?title=SteamCMD&action=raw (403 Forbidden to WebFetch)
- Tarball URLs (recorded only, NOT downloaded):
  - https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz
  - http://media.steampowered.com/client/steamcmd_linux.tar.gz
- Attempted 2026-11-26

## Status
The Valve wiki could not be fetched (HTTP 403 on both URL variants). Nothing below is verified from the Valve page. Items marked (unverified) are general knowledge and must be checked against the wiki before use.

## What it is
Valve's command-line Steam client used to install and update dedicated servers (`app_update`) and other Steam content.

## Install/build steps and build deps
Tarball URLs (both serve `steamcmd_linux.tar.gz`; the ich777 start script uses the media.steampowered.com one):
- `https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz`
- `http://media.steampowered.com/client/steamcmd_linux.tar.gz`

Extraction as used by ich777 start script:
`tar --directory <STEAMCMD_DIR> -xvzf <tarball>` then run `<STEAMCMD_DIR>/steamcmd.sh`.

Required 32-bit libs (verified only as used in ich777 Dockerfile on Debian): `lib32gcc-s1 lib32stdc++6 lib32z1`. Valve's own list not verified.

## Runtime deps
- 32-bit runtime libs above (unverified against Valve page).
- Outbound access to Steam CDN/servers.

## Entrypoint/CLI flags
Command syntax as used in the ich777 scripts (verified from those scripts, not the Valve page):
- `steamcmd.sh +login anonymous +quit`
- `steamcmd.sh +login <user> <pass> +quit`
- `steamcmd.sh +force_install_dir <dir> +login anonymous +app_update <appid> +quit`
- `steamcmd.sh +force_install_dir <dir> +login anonymous +app_update <appid> validate +quit`

Other flags (`-beta`, `-betapassword`, `validate` placement) are documented per README in ich777 as `GAME_ID=<appid> -beta <branch>`. Verify flags on the Valve wiki.

## Env vars
None defined by SteamCMD itself. (ich777 wraps it with env vars; see ich777-docker-steamcmd-server.md.)

## Ports
Not verified.

## Volumes/paths
- Install dir: `force_install_dir` target.
- Default steam cache/config under `~/.steam` (unverified; ich777 start script creates `${DATA_DIR}/.steam/sdk32` and copies `linux32/*` into it, which implies the steam client libs are expected there).

## User/UID & permissions
Not verified. ich777 runs SteamCMD as a non-root user `steam`.

## Config files
Not verified.

## Healthcheck
Not applicable.

## Version/asset naming
- Tarball name: `steamcmd_linux.tar.gz`.
- SteamCMD self-updates on first run (`+quit` after login), per ich777 script behavior.

## Arch support
Linux tarball is 32-bit Linux x86 binaries plus `linux32/` libs (per ich777 usage). Not further verified.

## Common errors
Not verified from Valve page. Known from ich777 script comments: missing 32-bit libs and missing `steamclient.so` in `~/.steam/sdk32` are the usual causes of startup failure (unverified).

## Gotchas
- Passwords on the command line are visible in `ps` output.
- Steam Guard / 2FA logins cannot be scripted non-interactively; use anonymous login for public server apps.
- The Valve wiki is required to confirm flags, error codes, and cache paths before shipping a Dockerfile.
