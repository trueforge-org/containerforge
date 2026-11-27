# Context: embystat

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/embystat/values.yaml + Chart.yaml | truecharts-embystat.md |
| https://hub.docker.com/v2/repositories/linuxserver/embystat/ (not in urls.txt; added per REQUIRED Docker Hub rule) | dockerhub-embystat.md |
| https://raw.githubusercontent.com/linuxserver/docker-embystat/5fa06c158344aeefbec98e0e211b34198f4f2063/Dockerfile (raw variant of the blob URL, same file) | linuxserver-dockerfile.md |
| https://github.com/mregni/EmbyStat | upstream-repo.md |
| https://github.com/mregni/EmbyStat/releases/tag/0.2.0-beta.30 | upstream-repo.md |

Skipped: github.com blob duplicate of Dockerfile; api.github.com releases/latest (covered by Dockerfile's tag resolution); JellyStat (mentioned by upstream, not fetched). No CLA, forgetool, containerforge, templated, binary-download or image-ref URLs in list.

Failures: none. Release asset list did not render on the HTML release page (9 assets claimed, names not shown); the asset name pattern is taken from the linuxserver Dockerfile.

## plan.md corrections
- None applied. Checked against fetched sources: MIT, port 6555, EXPOSE/HOME/jammy base, asset pattern EmbyStat-ubuntu-x64-v<TAG>.zip, 0.2.0-beta.30 tag, deprecation.
- Minor, not a correction: repo topics say netcore31 and README says .NET Core 3.1, while release notes say the project targets NET6.0. Plan's ".NET 6 self-contained" matches the release notes; not changed.
