# Context: avm-exporter

Fetched 2026-11-26. Summaries of every web source referenced by `draft.md` and `plan.md`.

## Source URL -> file

| Source URL | File |
| --- | --- |
| https://github.com/pdreker/fritz_exporter | github-pdreker-fritz-exporter.md |
| https://github.com/pdreker/fritz_exporter/blob/09a957c03cd7c253ea8147d0aecd1a06a08b6bbe/Dockerfile (fetched as raw) | github-pdreker-fritz-exporter.md |
| https://raw.githubusercontent.com/pdreker/fritz_exporter/fritzexporter-v4.0.3/README.md | github-pdreker-fritz-exporter.md |
| https://raw.githubusercontent.com/pdreker/fritz_exporter/fritzexporter-v4.0.3/LICENSE.md | github-pdreker-fritz-exporter.md |
| https://raw.githubusercontent.com/pdreker/fritz_exporter/fritzexporter-v4.0.3/fritzexporter/__main__.py | github-pdreker-fritz-exporter.md |
| https://github.com/pdreker/fritz_exporter/releases/tag/fritzexporter-v4.0.3 | github-pdreker-fritz-exporter.md |
| https://pdreker.github.io/fritz_exporter/ | docs-pdreker-github-io-fritz-exporter.md |
| https://pdreker.github.io/fritz_exporter/latest/ | docs-pdreker-github-io-fritz-exporter.md |
| https://hub.docker.com/r/pdreker/fritz_exporter | dockerhub-pdreker-fritz-exporter.md |
| https://pypi.org/pypi/fritz-exporter/json (plan.md's PyPI source; HTML page not fetched) | pypi-fritz-exporter.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/avm-exporter | truecharts-avm-exporter.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/avm-exporter/values.yaml | truecharts-avm-exporter.md |

## Skipped

- https://cla-assistant.io/trueforge-org/containerforge: CLA link.
- https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json: forgetool schema URL.
- https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu and `.../apps/python`: containerforge `apps/<base>` links.
- ghcr.io/trueforge-org/ubuntu, ghcr.io/trueforge-org/python (and digests): image references.
- docker.io/pdreker/fritz_exporter:4.0.3: image reference (Docker Hub page fetched).
- https://raw.githubusercontent.com/pdreker/fritz_exporter/fritzexporter-v${VERSION}/LICENSE.md: templated URL (`${`). The concrete 4.0.3 tag LICENSE.md was fetched.
- http://<container-ip>:9787: placeholder.

## Fetch failures / partial

- https://raw.githubusercontent.com/pdreker/fritz_exporter/fritzexporter-v4.0.3/src/fritzexporter/__main__.py and `.../src/fritzexporter/config.py`: HTTP 404 (the package is at the repo root). The root-level `fritzexporter/__main__.py` was fetched instead.
- https://raw.githubusercontent.com/pdreker/fritz_exporter/fritzexporter-v4.0.3/fritzexporter/config.py: HTTP 404. The env-var list and config defaults (plan.md section 1 and 6) are therefore UNVERIFIED against source.
- https://pdreker.github.io/fritz_exporter/latest/: landing page only; install, config, env, port and metrics pages were not followed.
- https://github.com/pdreker/fritz_exporter/releases/tag/fritzexporter-v4.0.3: release notes loaded, asset list did not render.
- https://hub.docker.com/r/pdreker/fritz_exporter: no architectures, ports, volumes or env vars.
- PyPI project HTML (`https://pypi.org/project/fritz-exporter/`) was not fetched; the JSON API was used.

## plan.md corrections

- plan.md section 1, the "Checksum" row: "none published separately; pin `==4.0.3`" changed to list the PyPI JSON sha256 values (wheel `f52e54fc...`, sdist `c4c7cb16...`) and keep "pin `==4.0.3`". Source: pypi-fritz-exporter.md (the JSON API publishes a sha256 for each file).

Unverified (left as is):

- plan.md section 1 env var list (`FRITZ_PORT`, `FRITZ_LOG_LEVEL`, `FRITZ_HOSTNAME`, `FRITZ_USERNAME`, `FRITZ_PASSWORD`, `FRITZ_PASSWORD_FILE`, `FRITZ_HOST_INFO`, `FRITZ_WIFI_CLIENT_INFO`, `FRITZ_CONNECTION_TIMEOUT`, `FRITZ_USE_TLS`, `FRITZ_DEVICE_PORT`, `FRITZ_REMOTE_ACCESS`) and the defaults in plan.md section 6: config.py not fetched. Only `FRITZ_LISTEN_ADDRESS` (127.0.0.1 default before the image sets 0.0.0.0), `FRITZ_ALLOW_UNSAFE_MD5_PASSWORD`, and `FRITZ_NAME` were confirmed in the README.
- plan.md section 1: "passwords longer than 32 chars give 401" is confirmed by the docs; "Env mode supports exactly one device" is confirmed by the README.
- plan.md section 1: "upstream publishes amd64, arm/v6, v7, arm64 images": not confirmed (Docker Hub page does not list arches).
- plan.md section 1: `/metrics` path: not confirmed in fetched sources (the chart's ServiceMonitor uses `/metrics`, which supports it).
- plan.md section 8, `--version` prints the plain version and exits 0: confirmed in `__main__.py` (prints `__version__` alone, `sys.exit(0)`).
- plan.md section 1 and section 10: exit 1 on invalid configuration and `Exporter is ready` log line: confirmed in `__main__.py`.
- plan.md section 1: `Python requirement >=3.14`, dependencies list, Apache-2.0 license, wheel name: confirmed (PyPI JSON; LICENSE.md).
- plan.md section 4: `LICENSE.md` exists at `fritzexporter-v4.0.3`: confirmed.
- plan.md section 1: "`ENV FRITZ_LISTEN_ADDRESS=0.0.0.0`, `EXPOSE 9787`, `USER 65534`, `ENTRYPOINT python -m fritzexporter`, creates `/etc/fritz`": confirmed.
