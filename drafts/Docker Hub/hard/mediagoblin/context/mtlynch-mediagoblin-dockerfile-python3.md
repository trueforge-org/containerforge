# mtlynch/mediagoblin Dockerfile-python3

**Source:** https://raw.githubusercontent.com/mtlynch/mediagoblin/master/Dockerfile-python3 (fetched 2026-11-26; blob URL in urls.txt is the same file)

**Note:** dev-environment Dockerfile (debian:buster), not the official release image. See `mediagoblin-docker-docs.md` for the official image.

## Base / stages
- FROM `debian:buster`; single stage.
- ARG/ENV: none (`VIRTUALENV_FLAGS` inline on one RUN only).

## Packages (apt)
- Bootstrap: automake, git, nodejs, npm, python3-dev, virtualenv
- Python: python3-alembic, -celery, -jsonschema, -kombu, -lxml, -migrate, -py, -pytest, -pytest-xdist, -six, -sphinx, -webtest
- Audio: gstreamer1.0-libav, -plugins-bad/base/good/ugly, libsndfile1-dev, python3-gst-1.0, python3-numpy, python3-scipy
- Video: gir1.2-gst-plugins-base-1.0, gir1.2-gstreamer-1.0, gstreamer1.0-tools, python3-gi

## Build commands
- `git clone git://git.savannah.gnu.org/mediagoblin.git -b master .`
- `git submodule init && git submodule update`
- `./bootstrap.sh`
- `VIRTUALENV_FLAGS='--system-site-packages' ./configure --with-python3`
- `make`; `./bin/python setup.py develop --upgrade`
- scikits.audiolab line commented out (Python 2 only)

## Users / paths
- WORKDIR `/opt/mediagoblin`; chown -R www-data:www-data
- `/var/www`: chown root:www-data, chmod g+w (Bower cache during make)
- `USER www-data` (no numeric UID)

## Config / setup
- COPY `mediagoblin/init/config.py` -> `/opt/mediagoblin/mediagoblin/init/config.py`
- mediagoblin.ini: appends audio and video media_types sections
- DB: sqlite default; `./bin/gmg dbupdate` at build
- Admin: `./bin/gmg adduser --username admin --password a --email admin@example.com`; `./bin/gmg makeadmin admin` (hardcoded dev creds, not for production)

## Entrypoint / CMD / ports
- ENTRYPOINT none; CMD `["./lazyserver.sh", "--server-name=broadcast"]`
- EXPOSE none; usage comment maps 6543
- VOLUME none; usage comment bind-mounts `mediagoblin` and `extlib`
- HEALTHCHECK none

## Gotchas
- Dev image: hardcoded admin credentials, Python 3 on Debian buster (EOL).
