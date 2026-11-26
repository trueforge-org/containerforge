# Context: feedcord

| Source URL | File |
| --- | --- |
| https://github.com/Qolors/FeedCord (+ blob Dockerfile @ c9568b9, raw README via master) | qolors-feedcord.md |
| https://dot.net/v1/dotnet-install.sh (+ redirect target) | dotnet-install.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/feedcord (+ raw Chart.yaml, values.yaml) | truecharts-feedcord.md |
| https://hub.docker.com/v2/repositories/qolors/feedcord/ and /tags?page_size=10 (HTML page not fetched) | dockerhub-feedcord.md |

Skipped: urls.txt has no CLA, forgetool, containerforge, templated, binary or image-ref URLs. hub.docker.com HTML not fetched; v2 JSON API used.

Failures: https://raw.githubusercontent.com/Qolors/FeedCord/main/README.md returned 404; one alternative (master) used and succeeded.

## plan.md corrections
- No edits. Unverified conflict (Docker Hub beta tag updated 2025-02-20 matches plan's v3.1.0 date, but the changelog conflict remains): README changelog (master) says latest is 3.0.0 (2025-02-10), while plan.md cites tag v3.1.0 (2025-02-20). Not checked against a releases API call; left for the plan author.
- Consistent with fetched master Dockerfile: sdk:9.0 build / aspnet:9.0 final, ENTRYPOINT dotnet FeedCord.dll.
