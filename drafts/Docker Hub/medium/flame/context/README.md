# Context: flame

| Source URL | File |
| --- | --- |
| https://github.com/pawelmalak/flame (+ raw .docker/Dockerfile @ 069b669) | pawelmalak-flame-dockerfile.md |
| https://github.com/pawelmalak/flame/wiki | pawelmalak-flame-dockerfile.md (sub-pages failed, no facts) |
| https://api.github.com/repos/pawelmalak/flame/releases/latest | flame-github-api-releases.md |
| https://github.com/pawelmalak/flame/releases/tag/v2.4.0 | flame-github-api-releases.md (covered by API) |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/flame (+ raw Chart.yaml, values.yaml) | truecharts-flame.md |
| https://hub.docker.com/r/pawelmalak/flame (+ v2 API repo and tags) | dockerhub-flame.md |

Skipped: urls.txt has no CLA, forgetool, containerforge, templated, binary or image-ref URLs.

Failures: github.com/pawelmalak/flame/wiki sub-pages ("There was an error while loading"); not retried. Wiki home only gave page list. hub.docker.com HTML not fetched; v2 JSON API used.

## plan.md corrections
- Edit 1: plan.md line 17 (Env vars row). Old: "`PASSWORD` (README examples use `change_me`, no default stated)." New: "`PASSWORD` (upstream Dockerfile sets default `flame_password`; Docker Hub run example uses `flame_password`)." Source: pawelmalak-flame-dockerfile.md (Dockerfile `ENV PASSWORD=flame_password`) and dockerhub-flame.md (run example).
- Consistent: version 2.4.0 (GitHub release, Docker Hub tag 2.4.0), port 5005, /app/data, root runtime (no USER), node:20 builder / node:20-alpine final, `CMD chown -R node /app/data && node server.js`.
- Unverified, not edited: plan line 14 claims about release signing; PASSWORD_FILE and `_FILE` behaviour (not in fetched sources); plan line 11 LICENSE.md (not checked).
- Note: plan line 9 says multiarch build failed under 2 GB limit (not checked, left).
