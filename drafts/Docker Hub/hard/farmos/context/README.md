# farmos context index

Fetched 2026-11-26. Summaries of the web sources referenced by draft.md and plan.md.

## Sources

| Source URL | Summary file |
| --- | --- |
| https://github.com/farmOS/farmOS | github-farmos-farmos.md |
| https://github.com/farmOS/farmOS/blob/c09e3f403a21e2c3073dd5db686981c99e0314b7/docker/Dockerfile | github-farmos-farmos.md (draft Dockerfile, 4.x, section "Version/release info") |
| https://github.com/farmOS/composer-project.git | github-farmos-composer-project.md |
| https://farmOS.org | docs-farmos-org.md |
| https://farmOS.org/hosting/install | docs-farmos-org-hosting-install.md (followed /hosting/requirements and /hosting/docker as sections) |
| https://hub.docker.com/r/farmos/farmos | dockerhub-farmos-farmos.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/farmos | truecharts-farmos.md |

Shared cache (docs/context/INDEX.md): no matches for these URLs.

## Skipped URLs

- https://github.com/farmOS/farmOS/releases/download/3.5.11/farmOS-3.5.11.tar.gz: direct binary download (asset name pattern recorded in github-farmos-farmos.md).
- https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu: containerforge apps/<base> link.
- Plan-only: forgetool `container-test.schema.json` URL (schema URL); image refs `ghcr.io/trueforge-org/ubuntu` and `docker.io/farmos/farmos:latest` (not web pages; Docker Hub page covered above).
- Repo-local paths in plan.md (`apps/bookstack`, `apps/phpmyadmin`, `apps/postgresql`, `apps/nginx`): not web sources, not fetched.

## Not fetched

- Ubuntu 26.04 package versions via Launchpad API (plan.md, named, no URL in the filtered list).
- Release asset list for 3.5.11 (release page list failed to load; API call not made because the list was already fetched before the budget rule changed).
- Drupal base image `drupal:10.6-php8.3-apache-bookworm` on Docker Hub: named in the upstream Dockerfile, not in the URL list; Docker Hub page fetched in an earlier pass showed no tag list.

## Fetch failures

- Release page https://github.com/farmOS/farmOS/releases/tag/3.5.11: asset list did not load.
- https://farmOS.org/hosting/requirements and /hosting/docker were followed in the main docs fetch (not failures).
- No 403/404 responses.

## plan.md corrections

- §1 Persistent path row: "Draft path `/var/www/html/sites` maps to `/opt/drupal/web/sites` upstream" -> "Upstream path is `/opt/drupal/web/sites`; the draft path `/var/www/html/sites` is not that path (base image symlinks `/var/www/html` to `/opt/drupal`, so it resolves to `/opt/drupal/sites`)". Source: github-farmos-farmos.md (upstream Dockerfile comment on symlink).
- §1 Build script row: `composer require farmos/farmos:${FARMOS_VERSION}` -> `composer require farmos/farmos:${FARMOS_COMPOSER_VERSION}` (`3.x-dev` for `3.x`, bare tag for a tagged release). Source: github-farmos-farmos.md (build-farmOS.sh).

Unverified conflicts (not edited):
- PHP version: plan targets PHP 8.5 (Ubuntu 26.04). Docs requirements page says PHP 8.4 (docs-farmos-org-hosting-install.md). CHANGELOG 3.5.11 says PHP 8.4.28 in the Docker image, but the 3.5.11 Dockerfile base is `php8.3` (github-farmos-farmos.md). Unresolved.
- License: plan §5 uses `GPL-2.0-only`; README and docs say GPL 2.0 with no -only/-or-later detail. Unverified.
- Plan §1 "Docker Hub latest = 4.x": Docker Hub page does not state the release; not verified here.
- Plan §8 probe `/core/install.php`: not verified.
