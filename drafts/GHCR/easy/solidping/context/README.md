# solidping context README

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/solidping/values.yaml | truecharts-solidping-values.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/solidping/Chart.yaml | truecharts-solidping-chart.md |
| https://github.com/fclairamb/solidping/blob/5e35c5e4a02b63f3e15c48ade8e6bbe4b5b4e070/Dockerfile (raw) | solidping-dockerfile-5e35c5e.md |
| https://github.com/fclairamb/solidping (README, raw main) | solidping-readme.md |
| https://github.com/fclairamb/solidping/pkgs/container/solidping | solidping-ghcr-package.md |
| https://github.com/fclairamb/solidping/blob/main/LICENSE | covered by solidping-license-v0.54.1.md (main not fetched separately) |
| https://raw.githubusercontent.com/fclairamb/solidping/v0.54.1/LICENSE | solidping-license-v0.54.1.md |
| https://solidping.io/docs | failed: DNS EAI_AGAIN |
| https://www.solidping.io/docs (alternative) | failed: HTTP 404 |

Skipped: none by category. No CLA, forgetool, containerforge app, templated, binary download or image-ref URLs were in the list. Release binaries and checksums are binary downloads, not fetched. No Docker Hub source (GHCR app).

Failures: 2 (solidping.io/docs DNS error; alternative www.solidping.io/docs 404). The README covers the same configuration facts.

## plan.md corrections
- No edits made.
- Verified, no edit: Dockerfile facts (distroless nonroot 65532, VOLUME /data, EXPOSE 4000, HEALTHCHECK `/app/solidping healthcheck`, ENTRYPOINT `serve`, `SP_DB_TYPE=sqlite`, `SP_DB_DIR=/data`); AGPL-3.0 license; port 4000; `SP_SERVER_LISTEN` default `:4000` (TrueCharts); `SP_ADMIN_PASSWORD` option.
- Unverified conflict (version): plan pins 0.54.1 and says latest is 0.54.1 (plan line 8, research 2026-11-25; mentions 0.55.0 on 2026-11-25). Today's GHCR listing shows 0.56 as latest and TrueCharts appVersion is 0.56.0. The human should re-check the version choice before building. Not edited.
- Resolved-by-source (plan line 158, not an edit): README says the generated first-login password is printed once at first start and can be retrieved with `docker logs solidping 2>&1 | grep "First login"`. Plan calls the log location UNVERIFIED; this is a README statement, not checked in code.
