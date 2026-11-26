# Context: appdaemon

Fetched 2026-11-26. Summaries of every web source referenced by `draft.md` and `plan.md`.

## Source URL -> file

| Source URL | File |
| --- | --- |
| https://github.com/AppDaemon/appdaemon | github-appdaemon-appdaemon.md |
| https://github.com/AppDaemon/appdaemon/blob/239dd4b130f98a8053058fbe82d6cce9d62e919d/Dockerfile (fetched as raw) | github-appdaemon-appdaemon.md |
| https://raw.githubusercontent.com/AppDaemon/appdaemon/4.5.16/scripts/start.sh | github-appdaemon-appdaemon.md |
| https://raw.githubusercontent.com/AppDaemon/appdaemon/4.5.16/conf/appdaemon.yaml.example | github-appdaemon-appdaemon.md |
| https://raw.githubusercontent.com/AppDaemon/appdaemon/4.5.16/LICENSE.md | github-appdaemon-appdaemon.md |
| https://raw.githubusercontent.com/AppDaemon/appdaemon/4.5.16/README.md | github-appdaemon-appdaemon.md |
| https://appdaemon.readthedocs.io/ | docs-appdaemon-readthedocs-home.md |
| https://appdaemon.readthedocs.io/en/latest/INSTALL.html | docs-appdaemon-readthedocs-install.md |
| https://appdaemon.readthedocs.io/en/latest/DOCKER_TUTORIAL.html | docs-appdaemon-readthedocs-docker-tutorial.md |
| https://pypi.org/project/appdaemon/ (HTML failed) | pypi-appdaemon.md (JSON API used) |
| https://pypi.org/pypi/appdaemon/json | pypi-appdaemon.md |
| https://hub.docker.com/r/acockburn/appdaemon | dockerhub-acockburn-appdaemon.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/appdaemon | truecharts-appdaemon.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/appdaemon/values.yaml | truecharts-appdaemon.md |

## Skipped

- https://cla-assistant.io/trueforge-org/containerforge: CLA link.
- https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json and `.../schemas/container-settings.schema.json`: forgetool schema URLs.
- https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu and `.../apps/python`: containerforge `apps/<base>` links.
- ghcr.io/trueforge-org/ubuntu, ghcr.io/trueforge-org/python (and digests): image references.
- docker.io/acockburn/appdaemon:4.5.16: image reference (Docker Hub page fetched).
- https://raw.githubusercontent.com/AppDaemon/appdaemon/${VERSION}/LICENSE.md: templated URL (`${`). The concrete 4.5.16 LICENSE.md was fetched.
- http://0.0.0.0:5050: bind-all address in config, not a URL to fetch.
- http://x:8123: placeholder HA URL.

## Fetch failures / partial

- https://pypi.org/project/appdaemon/: HTML returned a client challenge ("A required part of this site couldn't load"). The JSON API (`/pypi/appdaemon/json`) was fetched instead and gave the needed facts.
- https://hub.docker.com/r/acockburn/appdaemon: no architectures, ports, volumes or env vars on the page; tag `4.5.16` not listed.
- https://github.com/AppDaemon/appdaemon (repo root): not fetched directly; README at tag 4.5.16 was used.
- The upstream Dockerfile was fetched at commit 239dd4b (as the draft links), not at 4.5.16.

## plan.md corrections

- plan.md section 7, step 6 (the final `exec` line): "matches upstream `appdaemon -c $CONF "$@"`" was changed to say it matches upstream's final `exec uv run --frozen appdaemon -c $CONF "$@"` without the `uv run` wrapper. Source: github-appdaemon-appdaemon.md (`start.sh` at 4.5.16).

- plan.md section 1, the "Checksum source" row: "PyPI does not publish a separate checksum" changed to say the PyPI JSON API lists a sha256 per file (wheel `ca686e13...` for 4.5.16). Source: pypi-appdaemon.md.

Unverified (left as is):

- plan.md section 1 `Entry point appdaemon.__main__:main` and console script path: not checked.
- plan.md section 7 step 2: upstream copies `apps/apps.yaml.example` (with content), not a comment-only file. plan.md already lists this as a risk; left as is.
- plan.md section 4: the wheel license path (`dist-info` `licenses/LICENSE.md`): not checked.
- plan.md section 9: whether the HA CA plugin accepts a path for `cert_verify`: not checked.
- plan.md section 8: which paths answer 200 without HA: not checked.
- plan.md section 1 `Upstream env vars` list and the `DASH_URL`, `TIMEZONE`, `LATITUDE`, `LONGITUDE`, `ELEVATION` sed targets: confirmed against start.sh, no edit.
- Confirmed (no edit): PyPI `requires_python` `<3.15,>=3.10`; 4.5.16 upload date 2026-11-13; wheel-only, `py3-none-any`; license null on PyPI (LICENSE.md is Apache-2.0); port 5050; upstream `/conf` and `/certs` volumes; no USER upstream.
