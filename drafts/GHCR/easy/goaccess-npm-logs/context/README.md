# goaccess-npm-logs context README

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/goaccess-npm-logs/values.yaml + Chart.yaml | truecharts-goaccess-npm-logs.md |
| Docker Hub | none (image is GHCR: ghcr.io/xavier-hernandez/goaccess-for-nginxproxymanager) |
| https://raw.githubusercontent.com/xavier-hernandez/goaccess-for-nginxproxymanager/6044a67020e04752f962a76f95ff99f6cdb00701/Dockerfile | goan-wrapper-dockerfile-start.md |
| .../6044a67020e04752f962a76f95ff99f6cdb00701/resources/scripts/start.sh | goan-wrapper-dockerfile-start.md |
| .../6044a67020e04752f962a76f95ff99f6cdb00701/README.md | goan-wrapper-readme.md |
| https://packages.ubuntu.com/resolute/goaccess | ubuntu-goaccess-package.md |
| https://archive.ubuntu.com/ubuntu | ubuntu-archive.md (cache copy from docs/context) |

Skipped categories: api.github.com/repos/allinurl/goaccess and xavier repo API (repo metadata, not build input); github.com blob/repo HTML duplicates of raw files; goaccess.io and goaccess.io/man (docs, budget); archive.ubuntu.com already covered by cache; Dockerfile blob URL (duplicate of raw).
Not fetched: wrapper `logs/npm.sh` and `funcs/*.sh` (source, not docs); needed to settle the port 7880 vs 7890 conflict. Left UNVERIFIED in plan.md.

Failures: none.

## plan.md corrections

- None made. Facts checked (Dockerfile root user, EXPOSE 7880, VOLUME /opt/log, tini entrypoint, README env list, Ubuntu pin 1:1.9.4-1) match the fetched sources.
- Unresolved: port 7880 (EXPOSE/README) vs 7890 (npm.sh per plan.md, not fetched). Left as-is.
