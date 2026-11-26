# farmOS/composer-project (GitHub)

**Source URL(s) + fetch date**
- https://raw.githubusercontent.com/farmOS/composer-project/3.x/composer.json (branch 3.x, fetched 2026-11-26)
- Clone URL used by build: https://github.com/farmOS/composer-project.git (`PROJECT_REPO` in the upstream Dockerfile)

**What it is**
Composer project template that pulls `farmos/farmos` into a Drupal codebase. Used by `build-farmOS.sh` to create the farmOS tree in `/var/farmOS`.

**Install/build steps and build deps**
- `build-farmOS.sh` clones this repo, moves `.git` into the build dir and checks out `PROJECT_VERSION` (`3.x` default). Then `composer require farmos/farmos:<version>` and `composer install`.

**Runtime deps**
- Drupal packages from `https://packages.drupal.org/8` (composer repository).

**Composer.json (branch 3.x, full relevant content)**
- `name`: `farmos/project`; `type`: `project`; `license`: `GPL-2.0-or-later` (this is the template repo's license, not necessarily farmOS's).
- `require`: `farmos/farmos` `^3.0`, `oomphinc/composer-installers-extender` `^2.0`, `wikimedia/composer-merge-plugin` `^2.0`.
- `minimum-stability`: `dev`; `prefer-stable`: `true`.
- `extra.installer-paths`: `web/core` (drupal-core), `web/libraries/{$name}`, `web/modules/{$name}`, `web/themes/{$name}`, `drush/Commands/contrib/{$name}`, and `web/profiles/farm` for `farmos/farmos`.
- `extra.merge-plugin.require`: `web/profiles/farm/composer.libraries.json`, `web/profiles/farm/composer.project.json`.
- No `require-dev`, no `config`, no `php` requirement in this file.

**Binaries/entrypoint/CLI flags**
- None.

**Ports, volumes, user, healthcheck**
- None in this repo.

**Version/release info**
- Branch `3.x` tracks farmOS 3.x (`farmos/farmos: ^3.0`). The 4.x line uses a separate branch (`4.x` per the 4.x Dockerfile).

**Gotchas**
- The branch is floating; builds that do not pin a commit can change over time.
- `composer.json` in this repo has no PHP platform requirement; the farmOS core constraints are not visible here.
