# boinc: context index

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/boinc/values.yaml | truecharts-boinc.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/boinc/Chart.yaml | truecharts-boinc.md |
| https://hub.docker.com/v2/repositories/linuxserver/boinc/ (+ /tags?page_size=10) | dockerhub-boinc.md |
| https://raw.githubusercontent.com/linuxserver/docker-boinc/master/Dockerfile | github-linuxserver-docker-boinc-dockerfile.md |
| https://raw.githubusercontent.com/linuxserver/docker-boinc/f7a1ea8759dae4d9fed9069d86d25aceca07acc2/Dockerfile (= blob URL; identical to master) | github-linuxserver-docker-boinc-dockerfile.md |
| https://raw.githubusercontent.com/linuxserver/docker-boinc/master/README.md (= repo URL) | github-linuxserver-docker-boinc-readme.md |
| https://api.github.com/repos/BOINC/boinc (repo API, not fetched; /releases/latest fetched) and /releases/latest | github-boinc-boinc-release.md |
| https://raw.githubusercontent.com/BOINC/boinc/master/README.md (= repo URL https://github.com/BOINC/boinc) | github-boinc-boinc-release.md |
| https://boinc.berkeley.edu, https://github.com/BOINC/boinc/wiki | boinc-sites.md |
| https://packages.ubuntu.com/search?keywords=boinc-client | boinc-sites.md (failed: timeout) |

## Skipped
- Repo HTML https://github.com/linuxserver/docker-boinc (covered by raw README).
- Dockerfile blob URL at pinned commit (duplicate of raw, identical content).
- Repo API https://api.github.com/repos/BOINC/boinc (repo metadata; only license and release needed, license taken from README).
- Base images ghcr.io/linuxserver/baseimage-selkies:ubunturesolute (image ref); PPA ppa:costamagnagianfranco/boinc (not fetched).
- Icon PNG URLs (binary).

## Failures
- packages.ubuntu.com/search?keywords=boinc-client: timeout after 30 s. Not retried.

## plan.md corrections
- None. Verified against fetched data: server release server_release/1.6/1.6.3 has no assets; Dockerfile has no EXPOSE/VOLUME/USER; GUI ports 8080/8181 from env; license LGPL (README says LGPL v3 or later).
- Not changed, for the record: plan line 16 marks `/config` as UNVERIFIED for this image. linuxserver README documents `-v /config` for BOINC data and config.
- Hub newest tag is 8.2.8 (Ubuntu 24.04 packaging, `ls144`), not verified against the plan's resolute 26.04 target.
