# Context: owi2plex

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/owi2plex/values.yaml | truecharts-owi2plex.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/owi2plex/Chart.yaml | truecharts-owi2plex.md |
| https://hub.docker.com/v2/repositories/alturismo/owi2plex/ | dockerhub-owi2plex.md |
| https://hub.docker.com/v2/repositories/alturismo/owi2plex/tags?page_size=10 | dockerhub-owi2plex.md |
| https://github.com/alturismo/owi2plex/blob/master/Dockerfile | github-owi2plex-dockerfile.md (raw variant) |
| https://github.com/alturismo/owi2plex | FAILED: raw master README.md returned 404; content from Docker Hub readme instead |
| https://github.com/cvarelaruiz/owi2plex | github-cvarelaruiz-owi2plex.md (raw README) |

Skipped categories: none (no CLA, templated, binary or image-ref URLs in list).
Failures: 1 (https://raw.githubusercontent.com/alturismo/owi2plex/master/README.md, 404; not retried).

## plan.md corrections
- No edits made.
- Info (not a conflict): plan section 8 (Cron) marks the job line UNVERIFIED. cronjob.sh (github-owi2plex-dockerfile.md) shows the upstream call: `owi2plex -h <ip> -u <user> -p <pass> -b <bouquet> -o /owi2plex/enigma<bouquet>.xml`. Upstream schedule in sample_cron.txt is 04:45 daily; Dockerfile default is 00:00.
- Info: plan.md Dockerfile line 12 and PyPI/MPL claims were not re-checked here (PyPI not in this app's source list).
