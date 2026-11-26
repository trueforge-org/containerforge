# Context: zilean

| Source URL | File |
| --- | --- |
| http://+:8181 | not a source (ASP.NET bind prefix from Dockerfile env); not fetched |
| http://zilean:8181 | not a source (internal service hostname in test plan); not fetched |
| https://github.com/iPromKnight/zilean | zilean-readme-docs-dockerhub.md |
| https://github.com/iPromKnight/zilean/blob/HEAD/requirements.txt | zilean-dockerfile-requirements.md |
| https://github.com/iPromKnight/zilean/blob/ee5cbb7e41de282d8dd87f5a27e667a74370b196/Dockerfile | zilean-dockerfile-requirements.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/zilean | truecharts-zilean-chart.md |
| https://hub.docker.com/r/ipromknight/zilean | zilean-readme-docs-dockerhub.md |
| https://ipromknight.github.io/zilean | zilean-readme-docs-dockerhub.md (redirect page only) |

Skipped categories:
- Not sources: `http://+:8181` and `http://zilean:8181` (bind prefix and internal hostname, not fetchable).

Failures: none.

## plan.md corrections
- None. Dockerfile matches plan.md section "Upstream Dockerfile" (dotnet 9.0 sdk/aspnet alpine, alpine 3.18 python3 ~3.11, ASPNETCORE_URLS 8181, VOLUME /app/data, ENTRYPOINT ./zilean-api). requirements.txt matches plan's rank-torrent-name==1.5.3 note.
- Unverified (not edited): plan L10 license (no LICENSE file), plan L8 Docker Hub tags, plan L17 env-var list (settings.json keys) not checked in this pass.
