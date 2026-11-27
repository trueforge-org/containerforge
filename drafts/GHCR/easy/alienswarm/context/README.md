# Context index: alienswarm

Built 2026-11-27.

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/alienswarm/values.yaml | truecharts-alienswarm.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/alienswarm/Chart.yaml | truecharts-alienswarm.md |
| https://github.com/ich777/docker-steamcmd-server/blob/master/Dockerfile | ich777-docker-steamcmd-server.md (shared cache copy) |
| https://raw.githubusercontent.com/ich777/docker-steamcmd-server/master/Dockerfile | ich777-docker-steamcmd-server.md (shared cache copy) |
| https://raw.githubusercontent.com/ich777/docker-steamcmd-server/master/scripts/start.sh | ich777-docker-steamcmd-server.md (shared cache copy) |

Shared cache: ich777-docker-steamcmd-server.md copied from /workspaces/containers/docs/context (fetched 2026-11-26).

Skipped categories:
- Valve developer wiki: Dedicated_Server_Guide is 403 in the shared cache; the Valve wiki is treated as 403 per the shared cache rule, so Alien_Swarm_Dedicated_Server was not fetched and not retried.
- steampowered.com home: marketing page, not build source, not fetched.

Failures:
- https://developer.valvesoftware.com/wiki/Alien_Swarm_Dedicated_Server (not fetched: Valve wiki 403 per shared cache rule).
- https://developer.valvesoftware.com/wiki/Dedicated_Server_Guide (403 per shared cache, valve-dedicated-server-guide.md).

## plan.md corrections
None applied. Chart image pin, ports (27015 UDP and TCP), env values and data paths agree with truecharts-alienswarm.md and the cached ich777 summary.

Unverified (not edited, no source for these in this run):
- plan.md line 10 Docker Hub mirror digest and line 17 tarball size (binary not checked here).
- plan.md line 12 license claims: not checked.
