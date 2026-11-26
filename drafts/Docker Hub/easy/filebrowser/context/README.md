# Context index: filebrowser

Fetched 2026-11-26.

## Sources summarised

| Source URL | Summary file |
| --- | --- |
| https://github.com/filebrowser/filebrowser | github-filebrowser-filebrowser.md |
| https://github.com/filebrowser/filebrowser/blob/e8a388f840173580116f2743813d03b22286e44e/Dockerfile | github-filebrowser-filebrowser.md |
| https://raw.githubusercontent.com/filebrowser/filebrowser/e8a388f840173580116f2743813d03b22286e44e/Dockerfile | github-filebrowser-filebrowser.md |
| https://raw.githubusercontent.com/filebrowser/filebrowser/e8a388f840173580116f2743813d03b22286e44e/README.md | github-filebrowser-filebrowser.md |
| https://raw.githubusercontent.com/filebrowser/filebrowser/e8a388f840173580116f2743813d03b22286e44e/docker/common/healthcheck.sh | github-filebrowser-filebrowser.md |
| https://raw.githubusercontent.com/filebrowser/filebrowser/e8a388f840173580116f2743813d03b22286e44e/docker/common/defaults/settings.json | github-filebrowser-filebrowser.md |
| https://github.com/filebrowser/filebrowser/releases/tag/v2.63.23 | github-filebrowser-filebrowser.md |
| https://github.com/filebrowser/filebrowser/releases/download/v2.63.23/filebrowser_2.63.23_checksums.txt | github-filebrowser-filebrowser.md (followed to signed asset URL) |
| https://hub.docker.com/r/filebrowser/filebrowser | dockerhub-filebrowser-filebrowser.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/filebrowser | truecharts-filebrowser.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/filebrowser/values.yaml | truecharts-filebrowser.md |

## Skipped URLs

| URL | Reason |
| --- | --- |
| https://cla-assistant.io/trueforge-org/containerforge | CLA page (only the user can sign) |
| https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json | forgetool schema URL |
| https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json | forgetool schema URL |
| https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu | containerforge apps/<base> link |
| https://github.com/filebrowser/filebrowser/releases/download/v2.63.23/linux-amd64-filebrowser.tar.gz | direct binary download; pattern `linux-<arch>-filebrowser.tar.gz` recorded |
| https://github.com/filebrowser/filebrowser/releases/download/v2.63.23/linux-arm64-filebrowser.tar.gz | direct binary download; pattern recorded |
| ghcr.io/trueforge-org/ubuntu | ghcr image ref, not a web page |
| https://raw.githubusercontent.com/dominictarr/JSON.sh/.../JSON.sh | upstream build-time download, not a source page for this container |

Redirect, not a separate summary: https://filebrowser.org/cli/filebrowser (301 to https://github.com/filebrowser/filebrowser; the repo was summarised from the pinned commit README, so the CLI page was not fetched separately).

Named references without a URL, not fetched: `busybox:1.37.0-musl`, `alpine:3.23`, `tini`.

## Fetch failures

- https://raw.githubusercontent.com/filebrowser/filebrowser/e8a388f840173580116f2743813d03b22286e44e/docker/common/init.sh: HTTP 404. Retried at `master` (`.../master/docker/common/init.sh`): also 404. The upstream init.sh content is unverified.
- https://github.com/filebrowser/filebrowser/releases/tag/v2.63.23 asset list did not load (placeholder shown). Asset names taken from the checksum file instead.
- https://github.com/trueforge-org/truecharts/tree/master/charts/stable/filebrowser: values.yaml not shown in the listing; the raw values.yaml was fetched separately and succeeded.

## plan.md corrections

None made. No clear factual errors found. Items left unverified:
- plan.md section 7/1: upstream `init.sh` copies `defaults/settings.json` to `/config/settings.json` and execs `filebrowser --config`. init.sh was not fetchable (404). Unverified.
- plan.md section 8: `/health` route is registered in `http/http.go` at the tag. Not checked; the healthcheck script uses `/health`, which supports it.
- plan.md section 4: release tarball contains a flat `filebrowser` binary plus LICENSE and README.md (only arm64 listing was seen in plan). Not re-verified here.
- plan.md section 1: `busybox`/`tini` details are from the Dockerfile and match.
