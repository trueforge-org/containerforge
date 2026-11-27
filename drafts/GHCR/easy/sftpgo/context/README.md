# sftpgo context README

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/sftpgo/values.yaml | truecharts-sftpgo-values.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/sftpgo/Chart.yaml | truecharts-sftpgo-chart.md |
| https://api.github.com/repos/drakkan/sftpgo/releases/latest | github-api-sftpgo-latest-release.md |
| https://api.github.com/repos/drakkan/sftpgo | github-api-sftpgo-repo.md |
| https://raw.githubusercontent.com/drakkan/sftpgo/main/Dockerfile (also raw of blob URL below) | sftpgo-dockerfile-main.md |
| https://github.com/drakkan/sftpgo/blob/62ae9ba3957e9ed52b44a4f885e805e2d7b35972/Dockerfile | sftpgo-dockerfile-62ae9ba.md (fetched via raw pinned URL) |
| https://docs.sftpgo.com/latest/docker/ (follow-up from docs.sftpgo.com/latest) | sftpgo-docs-docker.md |
| https://docs.sftpgo.com/latest/env-vars/ (follow-up) | sftpgo-docs-env-vars.md |

Skipped: https://github.com/drakkan/sftpgo (HTML repo page, covered by API); https://sftpgo.com (marketing homepage, no build facts). No CLA, forgetool, containerforge app, templated, binary download or image-ref URLs were in the list. No Docker Hub source (GHCR app), though the docs page lists Docker Hub `drakkan/sftpgo` as a mirror.

Failures: 1 (https://docs.sftpgo.com/latest returned only the landing page, no facts; follow-ups used instead). Config-file docs page not fetched (follow-up budget used).

## plan.md corrections
- No edits made. Verified by fetched sources: SFTP 2022/tcp and admin 8080 (docs Docker page), USER 1000:1000, no EXPOSE/VOLUME, AGPL-3.0, v2.7.6 and asset names, upstream paths `/etc/sftpgo`, `/srv/sftpgo/{data,backups}`, `/var/lib/sftpgo`, `/usr/share/sftpgo`.
- Unverified conflict: plan.md line 17 says "8080/http admin and WebDAV". TrueCharts values put WebDAV on 10080/tcp. Docs Docker page does not state a WebDAV port. Not edited.
- Unverified: plan line 42 places templates/static/openapi in `/usr/local/share/sftpgo`; upstream Dockerfile uses `/usr/share/sftpgo`. Plan's own choice, not an upstream error, not edited.
