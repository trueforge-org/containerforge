# appdaemon.readthedocs.io: INSTALL (getting started)

**Source URL(s) + fetch date**
- https://appdaemon.readthedocs.io/en/latest/INSTALL.html (fetched 2026-11-26)

**Install methods**
- Docker, pip, and the Home Assistant add-on (add-on from the Community Add-ons repo, maintained by frenck).

**Docker**
- Multi-arch images from AppDaemon 4.1.0 onward, on Docker Hub as `acockburn/appdaemon`.
- Architectures: linux/arm/v6, linux/arm/v7, linux/arm64/v8, linux/amd64.
- Example: `docker run --name appdaemon --detach --restart=always --network=host -p 5050:5050 -v <conf_folder>:/conf -e HA_URL="http://homeassistant.local:8123" -e TOKEN="my_long_liven_token" acockburn/appdaemon`.

**Pip**
- Python requirement stated on this page: 3.10 or 3.11 (older text; PyPI says `>=3.10,<3.15`, see pypi-appdaemon.md).
- Install: `pip install appdaemon`. Upgrade: `pip install --upgrade appdaemon`. Run: `appdaemon -c <path_to_config_folder>`.
- Use a dedicated virtualenv, not Home Assistant's.
- Raspberry Pi OS may need `python-dev` and `libffi-dev`.

**Config directory**
- Docker: `/conf` (mounted from host). On first start AppDaemon writes sample config files there.
- Pip: `-c`. Without it, AppDaemon looks for `appdaemon.yaml` in `~/.homeassistant/`, then `/etc/appdaemon`, and raises an exception if neither exists.
- An `apps` directory must sit directly in the config directory.

**Default port**
- 5050 (HADashboard in the Docker example).

**Env vars (Docker)**
- `HA_URL`: Home Assistant URL. `TOKEN`: long-lived token.
