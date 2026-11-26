# WeblateOrg/docker Dockerfile (4.16.4-1)

Source URL: https://raw.githubusercontent.com/WeblateOrg/docker/4.16.4-1/Dockerfile (tag 4.16.4-1, fetched 2026-11-26)
Blob URL: https://github.com/WeblateOrg/docker/blob/4.16.4-1/Dockerfile

## Base / args / env
- `FROM python:3.11.2-slim-bullseye`; `ARG TARGETARCH`
- ENV: PYVERSION=3.11, VERSION=4.16.4, WEBLATE_EXTRAS="all,MySQL,zxcvbn", LANG/LC_ALL=C.UTF-8, HOME=/home/weblate, DJANGO_SETTINGS_MODULE=weblate.settings_docker, PYTHONUNBUFFERED=1
- SHELL bash with pipefail and xtrace.
- License label: GPL-3.0-or-later.

## RUN (in order)
1. User `weblate` (group weblate; groups root, tty; shell /bin/sh). `/home/weblate/.ssh` (700). Dirs data-test, test-images under site-packages; `/app/data`, `/app/cache` owned by weblate.
2. apt: nginx, openssh-client, ca-certificates, curl, gettext, git, git-svn, gnupg, subversion, tesseract-ocr, patch, unzip, xz-utils, others; libs gir1.2-pango-1.0, libxmlsec1-openssl, libjpeg62-turbo, libmariadb3, libldap-common, libenchant-2-2, libcairo-gobject2; build deps (bundler, ruby-dev, cmake, pkg-config, gcc, g++, -dev headers) later purged.
3. c_rehash; adds PostgreSQL apt repo bullseye-pgdg (key from postgresql.org); installs postgresql-client-15 (fallback postgresql-client).
4. `/usr/src/weblate`: `bundle install`, `bundle clean`.
5. Upgrades pip/wheel/setuptools to requirements.txt pins; builds cffi and lxml from source (`--no-binary :all:`).
6. Installs requirements.txt + `Weblate[$WEBLATE_EXTRAS]==$VERSION`. If VERSION contains "+", installs translate-toolkit and language-data from git and Weblate from `$WEBLATE_DOCKER_GIT_REVISION` archive.
7. Pre-generates phply parser; symlinks `/usr/local/share/weblate/examples/` into `/app/`.
8. Purges build deps, apt clean, removes /root/.cache, /tmp/*, apt lists.
9. Applies `*.patch` from /usr/src/weblate to site-packages.
10. Localtime UTC. group 0 + mode 770 on nginx, supervisor, /app/data, /app/cache, /run, home. /etc/passwd and /etc/group mode 664. pam_deny in /etc/pam.d/su.
11. `weblate-docker.pth` in site-packages pointing to /app/data/python.
12. /app/data/python/customize with empty `__init__.py`, `models.py` (owned weblate).
13. `chmod a+rx /app/bin/start`.

## COPY
- requirements.txt, Gemfile, patches -> /usr/src/weblate/
- etc -> /etc/
- start, health_check -> /app/bin/

## Runtime
- `USER 1000`
- `EXPOSE 8080`
- `VOLUME /app/data`, `/app/cache`
- `HEALTHCHECK` every 30s, timeout 3s, `/app/bin/health_check`
- `ENTRYPOINT ["/app/bin/start"]`; `CMD ["runserver"]`
- No WORKDIR (cd inside RUN only).
