# Context: reaparr

| Source URL | File |
| --- | --- |
| https://github.com/Reaparr/Reaparr | reaparr-readme.md |
| https://github.com/reaparr/reaparr | reaparr-readme.md (same repo, case-insensitive duplicate; not re-fetched) |
| https://github.com/Reaparr/Reaparr/blob/1e32ea55baa826a31cb4ceb3bdfd404bab2f3e11/docker/Dockerfile | reaparr-dockerfile.md (head + tail fetched) |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/reaparr | truecharts-reaparr-values.md |
| https://hub.docker.com/r/reaparr/reaparr | dockerhub-reaparr-reaparr.md |

Skipped categories: `http://+:7000` is not a URL (Kestrel listen binding, the DOTNET_URLS value); no fetch. Remaining list was pre-filtered.
Failures: none.

## plan.md corrections
- None made. Checked plan.md against fetched facts (port 7000 via EXPOSE ${PORT}, DOTNET_URLS, REAPARR_PLATFORM, UMASK=002, S6_SERVICES_GRACETIME, volumes /Config /Downloads /Movies /TvShows, base images, GPAC static build, glibc 2.39 donor). All consistent.
- Minor, not a version/path/port/env/licence error, so not edited: plan line 14 describes upstream publish as `-r linux-x64|linux-arm64`. Upstream Dockerfile uses `/p:ReaparrRuntimeIdentifier=${REAPARR_RUNTIME_IDENTIFIER}` (values linux-x64 / linux-arm64) plus `/p:Version` and `/p:InformationalVersion`, and no `-r` flag.
- Unverified (not covered by fetched sources): v0.40.0 release date, GPL-3.0 licence, and gpac/MP4Box details beyond the Dockerfile.
