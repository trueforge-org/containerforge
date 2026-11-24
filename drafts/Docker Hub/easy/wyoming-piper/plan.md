# wyoming-piper — implementation plan
> Source: ./draft.md · Target: apps/piper/ (already exists, no new app) · Difficulty: easy · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Upstream | https://github.com/rhasspy/wyoming-piper |
| Latest stable | `v2.5.4` (tags v2.5.2, v2.5.3, v2.5.4). PyPI `wyoming-piper` `2.5.4` too. Matches the draft tag `2.5.4` |
| Existing coverage | `apps/piper` already packages exactly this: `VERSION` `2.5.4`, `renovate: datasource=github-releases depName=rhasspy/wyoming-piper`, `SOURCE` `https://github.com/rhasspy/wyoming-piper`, port `10200`, `start.sh` runs `python3 -m wyoming_piper`. The TrueCharts chart `wyoming-piper` can therefore use `ghcr.io/trueforge-org/piper` |
| Renovate | `datasource=github-releases depName=rhasspy/wyoming-piper versioning=semver` (already in `apps/piper`) |
| License | PyPI metadata for `wyoming-piper` says MIT; the repo has `LICENSE.md` (HTTP 200). `apps/piper/docker-bake.hcl` says `AGPL-3.0-or-later`. UNVERIFIED which is right for the image (it also contains `piper-tts`, whose license was not checked). Resolve this before touching anything |
| Dependencies (PyPI 2.5.4) | `wyoming>=1.10.2,<2`, `regex`, `piper-tts>=1.8.0,<2`, `sentence-stream>=1.2.1,<2`; extras `http`, `zeroconf`, `zh`, `ja`, `th`, `web` (flask), `omnivoice` |
| Upstream CLI (`__main__.py` @ v2.5.4) | `--backend`, `--voice`, `--uri`, `--zeroconf`, `--data-dir`, `--download-dir`, `--upload-dir`, `--speaker`, `--noise-scale`, `--length-scale`, `--noise-w-scale`/`--noise-w`, `--sentence-silence`, `--auto-punctuation`, `--samples-per-chunk`, `--no-streaming`, `--update-voices`, `--use-cuda`, `--web-server`, `--web-server-host`, `--web-server-port`, `--web-server-allow` |
| Upstream Dockerfile reviewed | `0ed3421`; `docker_run.sh` runs `.venv/bin/python3 -m wyoming_piper --uri tcp://0.0.0.0:10200 --data-dir /data "$@"`; the web UI is off unless `--web-server --web-server-host 0.0.0.0` is passed |
| Port | `10200/tcp` |

## 2. Target layout

Not applicable: no new directory. The container already exists at `apps/piper/` (`Dockerfile`, `docker-bake.hcl`, `settings.yaml`, `container-test.yaml`, `start.sh`). Creating `apps/wyoming-piper/` would duplicate it and double the maintenance. Recommended action: close the draft as covered by `apps/piper` and point the TrueCharts chart at the `piper` image.

## 3. Base image

Not applicable (existing app). For reference, `apps/piper` uses `ghcr.io/trueforge-org/python:3.14.8@sha256:f099b700b824b7760cb846418f84a2c14c2f04992320506ab3ca5b79d3ac1232` with a comment "stay on python 3.14 until onnxruntime publishes cp315 wheels". The latest `onnxruntime` release (1.32.0) lists wheels only up to cp314, which confirms that pin is still needed.

## 4. Dockerfile

Not applicable: no new Dockerfile. Existing review notes for `apps/piper/Dockerfile` (do these only if the maintainers want a hardening pass; they are outside this draft's scope):
- It installs with `pip3 install ... "wyoming-piper==${VERSION}"` into the system Python, not `/app/venv`. Consistent with `apps/faster-whisper`.
- It has `COPY --chmod=0755 . /` followed by `COPY ./ /`, which is redundant.

## 5. docker-bake.hcl

Not applicable (exists). The only open item is the `LICENSE` value (section 1).

## 6. settings.yaml

Not applicable (exists). Possible improvement: `apps/piper/start.sh` reads `LOCAL_ONLY`, `PIPER_LENGTH`, `PIPER_NOISE`, `PIPER_NOISEW`, `PIPER_SPEAKER`, `PIPER_VOICE`, `NO_STREAMING`, but `apps/piper/settings.yaml` lists only `TZ`. Under the settings rules these env vars should be declared (`PIPER_VOICE` default `en_US-lessac-medium`, `PIPER_LENGTH` `1.0`, `PIPER_NOISE` `0.667`, `PIPER_NOISEW` `0.333`, `PIPER_SPEAKER` `0`, `LOCAL_ONLY` and `NO_STREAMING` empty). Do this as a separate `fix(piper): ...` PR, not under this draft.

## 7. start.sh

Not applicable (exists). The current script's flags all exist in v2.5.4 (checked against the argparse list above), it keeps data in `/config`, binds `0.0.0.0` and ends with `exec`.

## 8. container-test.yaml

Not applicable (exists, probes TCP `10200`). Matches the only port in `settings.yaml`.

## 9. Rootless and read-only-rootfs adaptations

Draft expectations (UID 568, read-only rootfs, `/data` pvc) are met by `apps/piper`: voices go to `/config` (`--data-dir /config --download-dir /config`) and the image runs as `USER apps`. Chart migration note: data previously in `/data` must be moved to the `/config` mount or re-downloaded.

## 10. Risks, caveats and open questions

- Duplicate of `apps/piper`; the plan's recommendation is no new container.
- License mismatch (MIT on PyPI vs AGPL-3.0-or-later in bake) UNVERIFIED.
- Voice models download at first start (needs internet unless `LOCAL_ONLY` set). A missing voice fails startup, as in the draft.
- The new optional web UI (`--web-server`, default port flag `--web-server-port`) is not exposed by `apps/piper`.

## 11. Build and test steps

Only if the piper app is touched later:

```sh
cd apps/piper
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name piper-probe --read-only --tmpfs /tmp -v piper-probe-config:/config piper:2.5.4
docker logs -f piper-probe
docker rm -f piper-probe; docker volume rm piper-probe-config
forgetool containers test --image piper:2.5.4 --config ./apps/piper/container-test.yaml
```

## 12. PR checklist

- No PR for this draft unless the maintainers insist on a separate `wyoming-piper` image (then: branch `feat/add-wyoming-piper`, commit `feat(wyoming-piper): add new container`, copy of `apps/piper`).
- For the optional follow-up: `fix(piper): declare env vars in settings.yaml`, PR template, `🤖 This PR is AI generated.` in Notes, CLA notice https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- Untested: everything above is read-only analysis; no image was built.
