# Context: send

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/send/values.yaml | truecharts-send.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/send/Chart.yaml | truecharts-send.md |
| https://gitlab.com/api/v4/projects/timvisee%2Fsend/repository/files/Dockerfile/raw?ref=master | gitlab-send-dockerfile.md |
| https://gitlab.com/timvisee/send/-/blob/master/Dockerfile | gitlab-send-dockerfile.md (same file) |
| https://gitlab.com/timvisee/send | not fetched (repo root; covered by README raw) |
| https://gitlab.com/timvisee/send/-/raw/master/README.md | gitlab-send-docs.md |
| https://gitlab.com/timvisee/send/-/raw/master/docs/docker.md (follow-up) | gitlab-send-docs.md |
| https://gitlab.com/timvisee/send/-/raw/master/server/config.js (follow-up) | gitlab-send-docs.md |
| https://gitlab.com/api/v4/projects/timvisee%2Fsend/releases | empty list ([]), no release data (see failures) |
| https://gitlab.com/timvisee/send/-/releases | not fetched (same release list as API; empty) |

Skipped categories: none beyond the duplicate/raw variants above.

## Failures
- https://gitlab.com/api/v4/projects/timvisee%2Fsend/releases: returned `[]` (no releases published via GitLab releases). Tag/asset info not available from this source.

## plan.md corrections
- None edited. Verified: server/config.js reads NODE_ENV (plan.md line 58 says upstream reading it is UNVERIFIED; it is confirmed, default `development`, Dockerfile/chart set `production`). Left for the plan author to update.
