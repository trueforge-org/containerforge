# Source: utkuozdemir/nvidia_gpu_exporter README (master)

Source URL(s) + date: https://raw.githubusercontent.com/utkuozdemir/nvidia_gpu_exporter/master/README.md (fetched 2026-11-27, 11 KB)

## Docker usage (from README)
```
docker run -d --name nvidia_gpu_exporter --restart unless-stopped \
  --gpus all -e NVIDIA_DRIVER_CAPABILITIES=utility -p 9835:9835 ...
```
- Scrape: `curl http://localhost:9835/metrics`.
- Extra args after image name pass to binary, e.g. `--collect.backend=exec`.

## Backends (flag --collect.backend)
- `nvml` (default on Linux per plan/README), `exec` (runs nvidia-smi, parses CSV; default on macOS and Linux -static), `demo` (synthetic metrics, no GPU).

## Containers / PID
- Per-process attribution needs host PID visibility: `--pid=host` / `hostPID: true`. Opt-in (see docs/CONFIGURE.md, not fetched). No runtime socket or k8s API permissions needed.

## Images
- Docker Hub: utkuozdemir/nvidia_gpu_exporter; GHCR: ghcr.io/utkuozdemir/nvidia_gpu_exporter.
- Artifacts, images, and Helm charts are signed with provenance attestations (INSTALL.md section).

## Gotchas
- README does not list --web.listen-address default or env var names (CONFIGURE.md not fetched).
