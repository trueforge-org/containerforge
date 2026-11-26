# context/ for tvhproxy

Fetched 2026-11-26.

## Sources

| Source URL | Summary file |
| --- | --- |
| https://github.com/jkaberg/tvhProxy (tvhProxy.py, requirements.txt, README, LICENSE, templates/device.xml @08096e6; repo page) | github-jkaberg-tvhproxy.md |
| https://github.com/chvb/docker-tvhproxy/blob/c1ed49d8924d9f5a16d581a1684c33d747d2111e/Dockerfile (raw) | github-jkaberg-tvhproxy.md (section "Install/build steps"; no separate file) |
| https://hub.docker.com/r/chvb/docker-tvhproxy | dockerhub-chvb-docker-tvhproxy.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/tvhproxy (values.yaml) | truecharts-tvhproxy.md |

## Skipped

- https://cla-assistant.io/trueforge-org/containerforge: CLA page, not a source.
- https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json: forgetool schema URL.
- https://github.com/trueforge-org/containerforge/tree/main/apps/python and .../apps/ubuntu: containerforge base links (the draft references them; not fetched).
- https://github.com/jkaberg/tvhProxy/archive/refs/heads/master.zip: direct archive download.
- https://raw.githubusercontent.com/jkaberg/tvhProxy/master/... and the `${TVHPROXY_COMMIT}` placeholder forms: replaced by the fetched commit `08096e6`.
- http://localhost, http://localhost:9981, http://test:test@localhost:9981, and the `<commit`/`<container-ip` draft placeholders: localhost and placeholder URLs.
- `docs/project-fireball.md`: local reference.

## Fetch failures

- chvb `docker-entrypoint.sh` (referenced by the upstream Dockerfile): not fetched. The `python /opt/tvhproxy/tvhProxy.py` launch line and the `su duser` step in plan.md are unverified.
- GitHub repo page: last commit date and tag count not shown; not a failure, just missing data.

## plan.md corrections

None made. Verified and consistent: archived repo (2018-06-13), BSD-3-Clause-style licence with three conditions, env var names and defaults (`TVH_CHUNK_SIZE` is `1024*1024`, which equals plan.md's `1048576`), port 5004 fixed in code, `/discover.json` route, `templates/device.xml` required, requirements (`flask`, `requests`, `gevent`, unpinned).

Items left as unverified (not edited):
- Plan section 1: "the chvb Dockerfile ... `su duser`" and "run command (`python /opt/tvhproxy/tvhProxy.py`)". The Dockerfile's ENTRYPOINT is `docker-entrypoint.sh`, which was not fetched. Unverified.
- Plan section 1: "Commit `08096e66` (2018-01-08)". The commit date is not shown by the fetch. Unverified.
- Plan section 6: "the schema requires `/config` to be listed". Not checked against the forgetool schema (not fetched).
- Plan section 8: `/discover.json` answers without a Tvheadend call. Route is present; the no-network behaviour is not checked in the fetched code.
