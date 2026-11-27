# Context: rapidphotodownloader

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/rapidphotodownloader/values.yaml + Chart.yaml | truecharts-rapidphotodownloader.md |
| https://raw.githubusercontent.com/ich777/docker-rapidphotodownloader/master/Dockerfile (blob URL duplicate) | ich777-rapidphotodownloader-dockerfile.md |
| https://raw.githubusercontent.com/ich777/docker-rapidphotodownloader/master/scripts/start.sh | ich777-rapidphotodownloader-start.md |
| https://api.github.com/repos/damonlynch/rapid-photo-downloader/releases/latest (403), recovered via https://github.com/damonlynch/rapid-photo-downloader/releases/latest | rapid-photo-downloader-release.md |
| https://damonlynch.net/rapid/documentation | rapidphotodownloader-docs.md (contents only) |

Skipped: GitHub repo page https://github.com/damonlynch/rapid-photo-downloader (covered by release page); blob Dockerfile URL (duplicate); https://packages.ubuntu.com/search?... (see failures); https://github.com/ich777/docker-rapidphotodownloader/blob/master/Dockerfile (duplicate).
No Docker Hub URL in list (image is GHCR).

Failures:
- https://packages.ubuntu.com/search?keywords=rapid-photo-downloader&searchon=names&suite=all&section=all: timed out (30s). Not retried. Package versions in plan.md were not re-checked.
- https://www.damonlynch.net/rapid: SSL certificate name mismatch (curl 60). Not retried.
- api.github.com release API: 403 rate limit; the HTML release page gave the tag (v0.9.37), so it is recorded as recovered.

## plan.md corrections
None. Checked plan facts against the fetched chart, Dockerfile, start.sh and release page (ports, env names, DL_URL pin 0.9.17, persistence paths, ENTRYPOINT, EXPOSE 8080). No clear factual error proven.
Unverified (not settled by these fetches): apt package versions by series (resolute 0.9.37-0ubuntu4, noble 0.9.36-0ubuntu3), upstream publish date 2026-02-18, signature key.
