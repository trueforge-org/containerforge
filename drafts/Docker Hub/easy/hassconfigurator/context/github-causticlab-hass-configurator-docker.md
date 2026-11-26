# causticlab/hass-configurator-docker (GitHub, the draft's Dockerfile)

**Source URL(s) + fetch date**
- https://raw.githubusercontent.com/causticlab/hass-configurator-docker/7ed3f9f60f4733bf16672a599c041621361d8b0a/Dockerfile (draft's blob link, same commit)
- https://raw.githubusercontent.com/causticlab/hass-configurator-docker/7ed3f9f60f4733bf16672a599c041621361d8b0a/run.sh
- Fetched 2026-11-26

**What it is**
Community Docker packaging of hass-configurator (Alpine, Python 3.9). Used by the TrueCharts chart.

**Install/build steps and build deps (Dockerfile at 7ed3f9f)**
- `FROM python:3.9-alpine`; `WORKDIR /app`; `ARG HC_BUILD_VERSION`.
- `RUN apk update && apk upgrade && apk add --no-cache bash git openssh && pip install --no-cache-dir hass-configurator==${HC_BUILD_VERSION} gitpython pyotp` (gitpython and pyotp unpinned).
- `COPY ./run.sh /app/`; `RUN chmod a+x ./run.sh`.
- `EXPOSE 3218`; `VOLUME /config`; `ENTRYPOINT ["/app/run.sh"]`.
- No ENV, USER, HEALTHCHECK, CMD. One LABEL (maintainer).

**Runtime deps**
Python 3.9, git, openssh, bash (Alpine). pip: hass-configurator, gitpython, pyotp.

**Binaries/entrypoint/CLI flags**
`run.sh` (fetched):
```
if [ ! -f /config/settings.conf ]; then
    echo "No configuration file found proceeding with default values"
    hass-configurator
else
    echo "Configuration file found starting configurator with provided settings"
    hass-configurator /config/settings.conf
fi
```
So the settings file at `/config/settings.conf` is optional (contrary to the Docker Hub wording, which says it "must hold" that file).

**Env vars, ports, volumes**
- No ENV in the Dockerfile. Port 3218. Volume `/config` (settings and the upstream's git config location).

**User/UID & permissions**
Not set: runs as root (no USER).

**Gotchas**
- The image pins `HC_BUILD_VERSION` via build-arg (the draft's `x86_64` chart tag is a separate published build).

**Contradictions with plan.md**
- plan.md section 1 says the Dockerfile is `python:3.9-alpine`, pip installs `hass-configurator==$HC_BUILD_VERSION gitpython pyotp`, `run.sh` starts with or without `/config/settings.conf`, `EXPOSE 3218`, `VOLUME /config`. Confirmed.
- plan.md section 1 says the upstream uses no USER. Confirmed (no USER; the Dockerfile also has no HEALTHCHECK).
- plan.md section 1 mentions that the draft's image is from "2021-era". The Docker Hub page says the latest push was about 8 months before fetch; the commit date was not read. Unverified.
