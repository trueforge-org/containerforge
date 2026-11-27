# Context: smtp-relay

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/smtp-relay/values.yaml + Chart.yaml | truecharts-smtp-relay.md |
| https://raw.githubusercontent.com/ix-ai/smtp/v0.7.7/Dockerfile, .../entrypoint.sh, .../README.md | ix-ai-smtp-upstream.md |
| https://packages.ubuntu.com/resolute/exim4-daemon-light, https://ftp.exim.org/pub/exim/exim4/ | exim-package-versions.md |

Skipped (not fetched): packages.debian.org/stable/exim4-daemon-light (plan says Debian is not used); https://ftp.exim.org docs pages and https://www.exim.org (licence and docs not read); https://github.com/Exim/exim (not fetched); https://github.com/ix-ai/smtp repo HTML (raw used); https://gitlab.com/ix.ai/smtp Dockerfile blob (raw variant used); CLA; forgetool schemas; containerforge app links; image refs (ghcr.io/ix-ai/smtp, public.ecr.aws debian).

Failures: none.

## plan.md corrections
- Applied 1 edit, plan.md line 10: "Latest upstream Exim source is 4.100.1 (https://ftp.exim.org/pub/exim/exim4/)" -> "Latest upstream Exim source is 4.100.2 (https://ftp.exim.org/pub/exim/exim4/, listing shows exim-4.100.2.tar.xz)". Source: ftp.exim.org directory listing (only exim-4.100.2.tar.xz is present in the 4.100 series; no 4.100.1 entry seen).
- Confirmed (no edit): ix-ai/smtp README archived notice and gitlab.com/egos-tech/smtp successor (plan line 9 correct); Ubuntu resolute exim4-daemon-light 4.99.1-1ubuntu1.5 (plan line 10 and section 4 pin correct); entrypoint and Dockerfile behaviours in plan line 16-17 match.
- Unverified (not edited): plan line 9 latest GitHub release v0.5.2 (2023-10-16) and plan line 12 licence claims come from API calls not made here.
