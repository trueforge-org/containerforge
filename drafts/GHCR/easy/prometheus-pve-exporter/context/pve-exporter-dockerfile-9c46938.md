# prometheus-pve-exporter Dockerfile at commit 9c46938

## Source URL(s) + date
- https://raw.githubusercontent.com/prometheus-pve/prometheus-pve-exporter/9c46938/Dockerfile (fetched 2026-11-27)
- Blob URL in list points to the same commit (not fetched separately)

## Build
- Stage `build` on `alpine:3.24.3`: apk add build-base, ca-certificates, libffi-dev, py3-build, py3-pip, python3, python3-dev, yaml-dev
- `COPY . /src/prometheus-pve-exporter`, WORKDIR there
- `python3 -m pip wheel -w dist --no-binary "cffi" --no-binary "pyyaml" -r requirements.txt && python3 -m build .`

## Final image
- `FROM alpine:3.24.3` (base, same stage); apk add ca-certificates py3-pip python3
- Copies /dist wheel(s) from build; `python3 -m venv /opt/prometheus-pve-exporter`; pip install wheel into venv
- `ln -s /opt/prometheus-pve-exporter/bin/pve_exporter /usr/bin/pve_exporter`; removes /src and /root/.cache
- `addgroup -S -g 101 prometheus`; `adduser -D -H -S -G prometheus -u 101 prometheus`
- `USER prometheus`; `EXPOSE 9221`
- `ENTRYPOINT [ "/opt/prometheus-pve-exporter/bin/pve_exporter" ]` (no CMD)

## User/UID
- prometheus uid 101 / gid 101 (system user, no home)

## Gotchas
- Exporter args (e.g. --web.listen-address) pass directly to pve_exporter.
- No HEALTHCHECK.
