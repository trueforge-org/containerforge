# Context index: slash

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/slash/values.yaml | truecharts-slash.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/slash/Chart.yaml | truecharts-slash.md |
| https://hub.docker.com/v2/repositories/yourselfhosted/slash/ | dockerhub-slash.md |
| https://hub.docker.com/v2/repositories/yourselfhosted/slash/tags?page_size=10 | dockerhub-slash.md |
| https://api.github.com/repos/yourselfhosted/slash | github-slash-dockerfile.md |
| https://raw.githubusercontent.com/yourselfhosted/slash/489efa67f3752e0d55e3487f820394d973322a2f/Dockerfile | github-slash-dockerfile.md |
| https://raw.githubusercontent.com/yourselfhosted/slash/main/docs/install.md | github-slash-docs.md |
| https://raw.githubusercontent.com/yourselfhosted/slash/main/server/profile/profile.go | github-slash-docs.md |

Skipped categories: `github.com/boojack/slash` and `github.com/yourselfhosted/slash` HTML pages and `blob/.../Dockerfile` HTML variant (same content as raw URL, covered); `api.github.com/.../contents/...` not applicable here.

Failures: none.

## plan.md corrections
None. Checked: Dockerfile stages and EXPOSE/VOLUME/ENV match; port 5231 matches; AGPL-3.0 SPDX matches; SLASH_MODE/SLASH_PORT/SLASH_DRIVER/SLASH_DSN match docs; data path `/var/opt/slash` and `slash_<mode>.db` match profile.go. Plan's SLASH_MODE "default dev in code" is confirmed by profile.go (not install.md, which the plan cites).
