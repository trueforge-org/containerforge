# context index: twtxt (fetched 2026-11-27)

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/twtxt/values.yaml | truecharts-twtxt.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/twtxt/Chart.yaml | truecharts-twtxt.md |
| https://raw.githubusercontent.com/nicholaswilde/docker-twtxt/3618126/Dockerfile | nicholaswilde-docker-twtxt-dockerfile.md |

Skipped: blob variant of the Dockerfile (duplicate); https://github.com/prologic/twtxt/archive/refs/tags (templated tarball, binary-download category); https://git.mills.io/prologic/twtxt/releases (HTML releases page, returned 200, not parsed; use api/tag info from chart appVersion 0.1.1); https://git.mills.io/prologic/twtxt and https://github.com/prologic/twtxt and https://github.com/nicholaswilde/docker-twtxt repo pages (same sources, not fetched).

Fetched, not summarised: https://twtxt.readthedocs.io (docs for the Python twtxt client, "Release: v1.3.2-dev"; not the Go server built into the image, so no build facts).

Failures:
- https://raw.githubusercontent.com/nicholaswilde/docker-twtxt/3618126/root/etc/s6-overlay/s6-rc.d/svc-twtxt/run : 404 (guessed path, not retried).
- https://raw.githubusercontent.com/prologic/twtxt/master/README.md : 404; alt https://raw.githubusercontent.com/prologic/twtxt/main/README.md : 404.
- https://api.github.com/repos/prologic/twtxt/releases/latest : returned no usable JSON (not retried).

## plan.md corrections
- None made. Not checked: plan facts about the Go server build and port 8000 match the Dockerfile EXPOSE 8000.
