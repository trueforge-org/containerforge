# docs.myspeed.dev Setup Linux

Source URL(s): https://docs.myspeed.dev/setup/linux (fetched 2026-11-27)

## Docker (documented)
- stable: `docker run -d -p 5216:5216 -v myspeed:/myspeed/data --restart=unless-stopped --name MySpeed germannewsmaker/myspeed`
- development: same with `germannewsmaker/myspeed:development`

## Other install methods (documented)
- automatic: install script `https://install.myspeed.dev` (stable) or `scripts/install.sh --beta` from development branch
- uninstall script: `scripts/uninstall.sh` with `--keep-data` or without
- manual: download pre-compiled binary for x64 or arm64 from latest GitHub release (linux-${ARCH} asset), `chmod +x`, run; available on port 5216
- from source: documented, not fetched in detail

## Notes
- Page does not list env vars in the fetched text
- Prometheus/Grafana support noted in upstream README (metrics at /api/prometheus per chart)
