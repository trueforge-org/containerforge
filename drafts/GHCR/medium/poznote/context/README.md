# Context: poznote (fetched 2026-11-27)

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/poznote/values.yaml | truecharts-poznote.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/poznote/Chart.yaml | truecharts-poznote.md |
| https://github.com/timothepoznanski/poznote | github-poznote-repo.md |
| https://github.com/timothepoznanski/poznote/releases/tag/6.153.0 | github-poznote-repo.md (not fetched; budget) |
| https://github.com/timothepoznanski/poznote/blob/5db51e94dfa0f6f204f267505153cf5fd143feb2/Dockerfile | github-poznote-dockerfile.md (raw variant) |
| https://raw.githubusercontent.com/timothepoznanski/poznote/5db51e94dfa0f6f204f267505153cf5fd143feb2/Dockerfile | github-poznote-dockerfile.md |

Skipped categories: none in the list.

Failures:
- https://api.github.com/repos/timothepoznanski/poznote/releases/latest: 403. Recovered by HTML releases/latest (6.161.0).

## plan.md corrections

No edits made. Unverified conflicts (version choices are maintainer decisions):
- plan.md line 8 says latest release is `6.159.0`. Fetched 2026-11-27: latest release page shows `6.161.0`.
- plan.md line 8 says the chart tag is `6.153.0`. Fetched chart values.yaml (2026-11-27) pin `ghcr.io/timothepoznanski/poznote:6.160.1-rootless`, appVersion `6.160.1`.
- plan.md line 10 says license MIT and default branch `develop`. Not verified: the fetched repo HTML did not expose the license text or branch.
