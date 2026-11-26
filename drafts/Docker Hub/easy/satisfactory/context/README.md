# satisfactory context

Fetched 2026-11-26.

## Sources

| Source URL | File |
| --- | --- |
| https://github.com/wolveix/satisfactory-server (Dockerfile, init.sh, run.sh, healthcheck.sh, README at 89015af; releases page) | github-wolveix-satisfactory-server.md |
| https://github.com/robtme/satisfactory-server (same repo, renamed; releases) | github-wolveix-satisfactory-server.md |
| https://hub.docker.com/r/wolveix/satisfactory-server | dockerhub-wolveix-satisfactory-server.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/satisfactory (values.yaml) | truecharts-satisfactory.md |

## Skipped

- https://cla-assistant.io/trueforge-org/containerforge: CLA page (skip rule).
- https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json: forgetool schema (skip rule).
- https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json: forgetool schema (skip rule).
- https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu: containerforge base app link (skip rule).
- https://github.com/trueforge-org/containerforge/tree/main/apps/steamcmd: containerforge base app link (skip rule).
- https://127.0.0.1:$SERVERGAMEPORT/api/v1 (plan.md): contains `$` and 127.0.0.1 (skip rule); covered by the healthcheck description in the GitHub summary.
- https://<ip (plan.md curl example): placeholder (skip rule).
- ghcr.io/trueforge-org/steamcmd (named base image in plan.md): image ref, not a web page (skip rule).
- ghcr.io/robtme/satisfactory-server (named in Docker Hub README text): image ref, not a web page (skip rule).

## Fetch failures

- https://store.steampowered.com/app/1690800/Satisfactory_Dedicated_Server/ and https://store.steampowered.com/app/1690800/: both returned the Steam storefront home page, not the app page. Recorded in steam-store-app-1690800.md. Not retried further.

## Notes

- The draft pins `wolveix/satisfactory-server:v1.9.11`; the chart values use `v1.10.0`; the latest release is `v1.10.0`.
- The image on Docker Hub is `wolveix`; the maintainer recommends `robtme/satisfactory-server`.
- Game files are not in the image; the server is fetched at runtime by SteamCMD (~8 GB+).

## plan.md corrections

- Section 1, "Wrapper version" row: "UNVERIFIED: what changed in 1.10.0; review it before implementing." -> replaced with the 1.10.0 changes from the release notes (SERVERADMINPASSWORD, SERVERNAME, SERVERPASSWORD, BACKUPLIMIT, Steam update fallback, clean shutdown). Source: github-wolveix-satisfactory-server.md (releases page).

Not changed (noted only):
- Section 1, "Upstream Dockerfile reviewed" says `init.sh` was not reviewed. It is now reviewed (github-wolveix-satisfactory-server.md); no factual error.
- Section 1, "Env (wrapper)" predates v1.10.0 and omits BACKUPLIMIT, SERVERADMINPASSWORD, SERVERNAME, SERVERPASSWORD. Omission, not a mistake; left as is.
- Section 1, "License": plan says the GitHub API reports MIT. The fetched pages carry no license text. Unverified, left as is.
- Section 1, "Application binary / amd64 only" and "Linux depot is x86_64 only": Steam app page could not be read. Unverified, left as is.

## Other unverified items

- Plan says Ports 15000/udp and 15777/udp were inferred and not used; the wrapper EXPOSE list (7777/udp, 7777/tcp, 8888/tcp) confirms the plan's omission.
- Plan's Dockerfile base/steamcmd tag and digest: not checked (ContainerForge's own image, not upstream).
