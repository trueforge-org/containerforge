# context README: cryptpad

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/cryptpad/cryptpad/cbeb1b76a778db9ba6c512c24f71b6186525d4d3/Dockerfile | upstream-github.md |
| https://raw.githubusercontent.com/cryptpad/cryptpad/cbeb1b76a778db9ba6c512c24f71b6186525d4d3/LICENSE | upstream-github.md |
| https://raw.githubusercontent.com/cryptpad/cryptpad/cbeb1b76a778db9ba6c512c24f71b6186525d4d3/docker-entrypoint.sh | upstream-github.md (followed sub-file) |
| https://api.github.com/repos/cryptpad/cryptpad/releases/latest | upstream-github.md (equivalent of releases page) |
| https://github.com/cryptpad/cryptpad | upstream-github.md (repo root, covered) |
| https://github.com/cryptpad/cryptpad/blob/cbeb1b76a778db9ba6c512c24f71b6186525d4d3/Dockerfile | upstream-github.md (same as raw) |
| https://hub.docker.com/v2/repositories/cryptpad/cryptpad/tags/version-5.5.0 | dockerhub-tag.md |
| https://hub.docker.com/r/cryptpad/cryptpad | not fetched (Docker Hub HTML, JS-rendered; tag API covers it) |
| https://cryptpad.fr | not fetched (marketing site) |
| https://docs.cryptpad.org/en | not fetched (docs index; no install page fetched within budget) |

Skipped: TrueCharts tree page (chart reference, not build source).
Failures: none.

## plan.md corrections
None edited. Checked against fetched sources:
- Dockerfile at cbeb1b76, entrypoint behaviour, env vars, VOLUMEs, UID 4001, EXPOSE 3000, HEALTHCHECK: consistent with plan section 1.
- Release 2026.10.1 exists (API): consistent with plan.
- Digests for version-5.5.0 match plan line 23.
Notes (not conflicts, no edit): plan line 8 says the Tags API returned 403; the Docker Hub v2 tag endpoint returned 200 in this pass. The plan's sed expression for `installMethod` is now confirmed verbatim (plan line 56 UNVERIFIED).
