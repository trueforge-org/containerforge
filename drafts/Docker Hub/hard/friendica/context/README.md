# Context: friendica

Fetched 2026-11-26.

## Sources

| Source URL | Summary file |
| --- | --- |
| https://github.com/friendica/docker/blob/91cb08d73a60af3dc355b0e6ebeaa898389cea5b/2026.05/apache/Dockerfile | github-friendica-docker.md |
| https://raw.githubusercontent.com/friendica/docker/master/README.md | github-friendica-docker.md |
| https://github.com/friendica/friendica | github-friendica-friendica.md |
| https://raw.githubusercontent.com/friendica/friendica/2026.05/composer.json | github-friendica-friendica.md |
| https://github.com/friendica/friendica/releases/tag/2026.05 | github-friendica-friendica.md |
| https://friendi.ca | docs-friendi-ca.md |
| https://hub.docker.com/_/friendica | dockerhub-friendica.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/friendica | truecharts-friendica.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/friendica/values.yaml | truecharts-friendica.md |

Shared index (`/workspaces/containers/docs/context/INDEX.md`): no matches.

## Skipped

| URL | Reason |
| --- | --- |
| https://cla-assistant.io/trueforge-org/containerforge | CLA link, not a source |
| https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu, apps/bookstack, apps/phpmyadmin, apps/mariadb, apps/valkey (plan.md) | containerforge apps links |
| https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json | forgetool schema URL |
| ghcr.io/trueforge-org/ubuntu, ghcr.io/trueforge-org/python-node etc. | ghcr image refs, not web pages |
| https://files.friendi.ca/friendica-all-in-one-${VERSION}.tar.gz (and .asc, `friendica-full`, `friendica-addons`) | direct archive downloads (recorded in github-friendica-docker.md; not downloaded) |
| https://github.com/tianon/gosu/releases/download/... | direct binary download (upstream build only) |
| keyserver.ubuntu.com, keys.openpgp.org | GPG key servers, not sources |
| https://dir.friendica.social/servers, https://wiki.friendi.ca, install/requirements pages on friendi.ca | not followed (not install/config facts needed for the container; the wiki was not fetched) |

## Fetch failures

- https://github.com/friendica/friendica/releases/tag/2026.05: the asset list did not load ("error while loading"). Asset names not confirmed.
- Upstream `/entrypoint.sh` in friendica/docker was not fetched (only the Dockerfile and README).

## plan.md corrections

- plan.md section 6 (env): changed the database env names from `FRIENDICA_DB_HOST`, `FRIENDICA_DB_PORT`, `FRIENDICA_DB_NAME`, `FRIENDICA_DB_USER`, `FRIENDICA_DB_PASSWORD` to the upstream names `MYSQL_HOST`, `MYSQL_PORT`, `MYSQL_DATABASE`, `MYSQL_USER`, `MYSQL_PASSWORD`. Source: `github-friendica-docker.md` (friendica/docker README env table). The sentence about the names being this image's own was replaced.

## Checked, not edited

- plan.md section 1 "License AGPL-3.0-or-later (UNVERIFIED whether or later)": composer.json `license` is `AGPL-3.0+`, which means or-later. Consistent with the plan's bake value; no edit. Source: `github-friendica-friendica.md`.
- plan.md section 1 "PHP requirement UNVERIFIED (8.5)": composer.json `require.php` includes `8.5.*`. Supported by the app; no edit. Source: `github-friendica-friendica.md`.
- plan.md section 1 "Env vars (app)": upstream names listed in the plan (MYSQL_*, FRIENDICA_ADMIN_MAIL, FRIENDICA_URL, FRIENDICA_TZ, FRIENDICA_LANG) are confirmed by the README. No edit.

## Unverified (no edit)

- plan.md section 7 step 5 "Friendica's documented cron entry point is `bin/worker.php`". The upstream image README documents a cron container that uses `cron.sh` as its startup command. The `bin/worker.php` path is not confirmed in the fetched text.
- plan.md section 4 step 6 symlink plan for `/app/www/config`, `smarty3`, `proxy`: upstream writes to `/usr/src/friendica/config` and `view/smarty3`; this is consistent with the plan but not separately verified.
- plan.md section 6 "ports 8080": not contradicted by any source; the upstream image listens on 80 (the plan already notes this).
