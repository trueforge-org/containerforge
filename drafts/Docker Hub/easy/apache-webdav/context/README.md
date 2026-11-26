# Context: apache-webdav

Fetched 2026-11-26. Summaries of every web source referenced by `draft.md` and `plan.md`.

## Source URL -> file

| Source URL | File |
| --- | --- |
| https://github.com/mgutt/docker-apachewebdav | github-mgutt-docker-apachewebdav.md |
| https://github.com/mgutt/docker-apachewebdav/blob/master/Dockerfile | github-mgutt-docker-apachewebdav.md |
| https://raw.githubusercontent.com/mgutt/docker-apachewebdav/master/README.md | github-mgutt-docker-apachewebdav.md |
| https://raw.githubusercontent.com/mgutt/docker-apachewebdav/master/docker-entrypoint.sh | github-mgutt-docker-apachewebdav.md |
| https://raw.githubusercontent.com/mgutt/docker-apachewebdav/master/conf/conf-available/dav.conf | github-mgutt-docker-apachewebdav.md |
| https://hub.docker.com/r/apachewebdav/apachewebdav | dockerhub-apachewebdav-apachewebdav.md |
| https://github.com/apache/httpd | github-apache-httpd.md |
| https://httpd.apache.org/ (website; the draft's link, covered by the docs landing) | docs-httpd-apache-org-home.md |
| https://httpd.apache.org/docs/ | docs-httpd-apache-org-home.md |
| https://httpd.apache.org/docs/2.4/mod/mod_dav.html | docs-httpd-apache-org-mod-dav.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/apache-webdav | truecharts-apache-webdav.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/apache-webdav/values.yaml | truecharts-apache-webdav.md |
| Named reference: apt `apache2` (no URL in draft; packages.ubuntu.com/apache2 fetched) | packages-ubuntu-com-apache2.md |
| Named reference: Ubuntu apt archive (apt usage; shared summary from docs/context) | ubuntu-archive.md |

## Skipped

- https://cla-assistant.io/trueforge-org/containerforge: CLA link.
- https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json: forgetool schema URL.
- https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu: containerforge `apps/<base>` link.
- ghcr.io/trueforge-org/ubuntu (and `:26.04@sha256`): image reference.
- docker.io/apachewebdav/apachewebdav:latest: image reference (Docker Hub page fetched instead).
- docker.io/apachewebdav/... and `apache/httpd`-style image names: image refs only.
- http://<ip>, http://<container-ip>: placeholders.

## Fetch failures / partial

- https://github.com/apache/httpd: the README fetch (raw trunk) returned only the word "README". No license or build text obtained.
- https://httpd.apache.org/docs/: landing page only; no version number and no install or config sections (those live under /docs/2.4/, not fetched).
- https://packages.ubuntu.com/apache2: search-result view; depends list and file list not shown.
- https://raw.githubusercontent.com/mgutt/docker-apachewebdav/master/conf/sites-available/default.conf (the vhost config with `RequestHeader edit Destination`) was not fetched; plan.md's claim about it is unverified.

## plan.md corrections

- plan.md section 10, the line beginning "Draft: no usable default config upstream and users must be created by hand": edited to "Draft: multiple users must be created by hand (upstream generates its config and a single user from env)". Source: github-mgutt-docker-apachewebdav.md (entrypoint and README: env `USERNAME`/`PASSWORD` create one user; the config is generated from conf/ at start; only additional users need a mounted `/user.passwd`).

Unverified (left as is):

- plan.md section 1 `RequestHeader edit Destination ^https http early` and the `*:80` vhost: `sites-available/default.conf` not fetched.
- plan.md section 1 apt module and file list (dav, dav_fs, dav_lock, auth_digest, authn_file, headers, rewrite; `htpasswd` in `apache2-utils`): not shown by packages.ubuntu.com.
- plan.md section 7 and 8 statements about `log_config`/`unixd` built-in, `apache2 -l`, `TypesConfig`, and `forgetool` `statusCode` handling: not in these sources.
- plan.md sections 5 and 12: renovate `repology` option: not checked.
- Port: the chart uses 8384 -> 80 (truecharts-apache-webdav.md); plan.md does not mention 8384.
- Confirmed (no edit): version 2.4.66-2ubuntu2.7 in resolute (packages.ubuntu.com); mgutt wrapper base `httpd:2.4.43-alpine`; PUID/PGID default 1000 in the entrypoint; Apache-2.0 for httpd (plan.md, not re-checked on repo).
