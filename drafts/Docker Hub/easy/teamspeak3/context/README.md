# teamspeak3 context index

Fetched 2026-11-26.

## Source URL -> file

| Source URL | Summary file |
| --- | --- |
| https://raw.githubusercontent.com/TeamSpeak-Systems/teamspeak-linux-docker-images/88586dc62959fd95700968a42eab6cf093cd9f86/alpine/Dockerfile | github-teamspeak-systems-teamspeak-linux-docker-images.md |
| https://raw.githubusercontent.com/TeamSpeak-Systems/teamspeak-linux-docker-images/88586dc62959fd95700968a42eab6cf093cd9f86/alpine/entrypoint.sh | github-teamspeak-systems-teamspeak-linux-docker-images.md (followed, same repo) |
| https://hub.docker.com/_/teamspeak | dockerhub-teamspeak.md |
| https://www.teamspeak.com/en/downloads/ | docs-teamspeak-downloads.md |
| https://www.teamspeak.com/en | docs-teamspeak-home.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/teamspeak3 | truecharts-teamspeak3.md |

## Skipped URLs

| URL | Reason |
| --- | --- |
| https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu | containerforge apps/<base> link |
| ghcr.io/trueforge-org/ubuntu:26.04@sha256:... | image ref, not a web page |
| https://files.teamspeak-services.com/releases/server/3.13.9/teamspeak3-server_linux_amd64-3.13.9.tar.bz2 | direct binary download. Asset pattern: `teamspeak3-server_linux_amd64-<ver>.tar.bz2` (glibc, amd64). Alpine build: `teamspeak3-server_linux_alpine-<ver>.tar.bz2` (in upstream Dockerfile) |
| arm64 tarball `teamspeak3-server_linux_arm64-3.13.9.tar.bz2` (named in plan only, no URL) | not a link in the draft; plan says it returns 404 (not re-tested) |
| https://raw.githubusercontent.com/trueforge-org/forgetool/... (schema URLs in settings.yaml / container-test.yaml sections of plan) | forgetool schema URLs |
| docs/project-fireball.md (draft "About") | local file, not web |

Named references: Docker Hub `teamspeak` image (covered by dockerhub-teamspeak.md); TeamSpeak 6 server (only on the downloads page, not referenced by the draft; not summarised).

## Fetch failures
None.

## plan.md corrections
None made. Checked against the sources:
- Ports, env var names (`TS3SERVER_QUERY_PORT`, `TS3SERVER_FILETRANSFER_PORT`, `TS3SERVER_DEFAULT_VOICE_PORT`, `TS3SERVER_QUERY_SSH_PORT`, `TS3SERVER_DB_*`, `TS3SERVER_LOG_*`), the entrypoint's ini keys and the 3.13.9 version are consistent with upstream.
- Contradiction noted, not edited: the plan's checksum `35049b...` is for the glibc amd64 tarball. Upstream's Dockerfile uses a different checksum for the alpine tarball (`82f58acd...`). The fetched downloads page did not show any SHA256 values, so the plan's 35049b... value is **unverified** here.
- Unverified, not edited: plan section 1 says the downloads page publishes a SHA256 for each file. The fetched page showed no checksums.
- Unverified: the plan's `.ts3server_license_accepted` and `query_ip_whitelist.txt` binary-string claims (not checkable from these sources). The entrypoint itself does not mention `.ts3server_license_accepted`.
- Unverified: plan section 1 says the Docker Hub readme names `TS3SERVER_IP_WHITELIST`/`BLACKLIST`. Confirmed on Docker Hub, but the entrypoint reads `TS3SERVER_IP_ALLOWLIST`/`BLOCKLIST` (consistent with the plan).
- Unverified: the plan's claim that "`TS3SERVER_LICENSE=accept` is read by the server binary". Docker Hub documents it, the entrypoint does not read it.
