# fabulinus — implementation plan
> Source: ./draft.md · Target: apps/fabulinus/ · Difficulty: hard (BLOCKED, do not implement) · Role: main · Verified on 2026-11-24

**Recommendation: do not build this container.** There is no redistributable artifact (closed-source server, image last pushed 2023-11-17, GPU variant, root by default). The sections below record what was verified and what a build would need if TitanML ever publishes a redistributable artifact. Nothing below should be created under `apps/` until the blockers in section 10 are resolved.

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | None. Docker Hub tags are `latest`, `latest-cpu`, `<git-sha>-cpu`, `buildcache-cpu/gpu`; newest push 2023-11-17 (draft tag `latest-cpu, latest-gpu` matches) |
| Renovate | Not applicable: no versioned artifact. A docker datasource on `tytn/fabulinus` would only see hash tags |
| License | UNVERIFIED: no license text found. `titanml/takeoff-community` has only `.github`, `.gitignore`, `README.md` (docs repo, no source). Treat as proprietary |
| Source URL | https://github.com/titanml/takeoff-community (docs/README only). The draft's second link `takeoff-communitys` is a typo and was not used |
| Per-arch downloads | None. Hub tags published for amd64 only (draft: arm64 `no`) |
| Checksum source | None |
| Upstream Dockerfile | None public (draft: `-`). Hub description: "server component of the TitanML Takeoff server", started through the `iris` launcher (`pip install titan-iris`), example `iris takeoff --model tiiuae/falcon-7b-instruct --device cpu --port 8000` |
| Ports | Container listens on 80: the Hub run example maps host 8000 to container 80 (`-p 8000:80`), and TrueCharts targetPort is 80. The iris example also uses `--port 8000`. The draft's 3000 is inferred and not supported by any source |
| Paths | `/code/models` per the TrueCharts chart. UNVERIFIED otherwise |

## 2. Target layout

Not applicable: the container is blocked, so no `apps/fabulinus/` should be created. If unblocked, the layout would be the standard five files (`Dockerfile`, `docker-bake.hcl`, `settings.yaml`, `container-test.yaml`, `start.sh`); no `defaults/`, `etc/`, `health/` and no `DOWNSTREAM_CHANGES.md` (nothing uses it as a base).

## 3. Base image

Conditional: `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a`. The draft says ubuntu alone is enough, but the real stack (Python inference, torch, CUDA) is unknown, so python or a CUDA base may be needed. Closest sibling: `apps/faster-whisper` (ML inference, not GPU-specific).

## 4. Dockerfile

Not applicable: there is nothing legitimate to download. `COPY --from=tytn/fabulinus:latest-cpu` is not acceptable: the image is closed-source, untagged by version, runs as root, and ContainerForge could not verify its license, checksum or contents. If a vendor artifact appears the steps would be the usual ones: `ARG VERSION`/`TARGETARCH`, download plus checksum verify to `/app`, license files to `/usr/share/licenses/fabulinus/`, `ENV HOME=/config` with caches in `/tmp`, `COPY --chmod=0755 . /`, `EXPOSE`, `VOLUME /config`, final `USER apps`.

## 5. docker-bake.hcl

Not applicable (blocked). If unblocked: `APP="fabulinus"`, `VERSION` with a `// renovate:` comment matching the real source, `LICENSE` set to the real license (not `Proprietary` unless redistribution is permitted), `SOURCE="https://github.com/titanml/takeoff-community"`, and the four standard targets plus `group "default"`.

## 6. settings.yaml

Not applicable (blocked). Do not invent ports or env vars. Facts now available: Hub env `TAKEOFF_MODEL_NAME` and `TAKEOFF_DEVICE` (`cuda` for GPU); container port 80; TrueCharts env `TAKEOFF_QUANT_TYPE`, `TAKEOFF_MAX_BATCH_SIZE`, `TAKEOFF_DISABLE_BATCHING`; model path `/code/models` (TrueCharts).

## 7. start.sh

Not applicable (blocked). A future script would need: model directory in `/config/models` (not `/code/models`), `HOME`/HuggingFace caches in `/tmp` (or `/config` if model persistence is intended), bind `0.0.0.0`, `exec` the server.

## 8. container-test.yaml

Not applicable (blocked). Would need a tcp probe for every port in settings.yaml and a `filePaths` entry for the server entrypoint.

## 9. Rootless and read-only-rootfs adaptations

The draft's TrueCharts expectations (runAsUser 0, readOnlyRootFilesystem false, `/code/models` persistence, GPU device access) conflict with `USER apps` (568) and a read-only rootfs. Unknown write paths in a closed image cannot be remapped safely. GPU access cannot be satisfied by an unprivileged CPU-only ubuntu image.

## 10. Risks, caveats and open questions

- BLOCKER: closed-source, no redistributable artifact, no public Dockerfile, no license information.
- BLOCKER: stale. The upstream repo was archived by its owner on 2024-01-22 and its README says it is no longer maintained. Last Hub push 2023-11-17 (not re-confirmed; the Hub page says "updated about 3 years ago"), README says the Takeoff pro edition is sold separately (contact email). A "community edition" license may forbid redistribution. UNVERIFIED.
- BLOCKER: GPU variant (`latest-gpu`) needs NVIDIA runtime; the draft marks both amd64 and arm64 as `no`.
- Draft caveat "first start may download large model files" is plausible but UNVERIFIED.
- Suggested action: close the item as `won't port` or ask TitanML for terms; alternatives are maintained inference servers (for example a vLLM or llama.cpp image) if the chart is still needed.

## 11. Build and test steps

Not applicable: do not build. If unblocked, follow the protocol for `apps/fabulinus`: `docker buildx bake --print`; `docker buildx bake --set image-local.platform=linux/amd64 image-local`; `docker run --rm -d --name fabulinus-probe --read-only --tmpfs /tmp -v fabulinus-probe-config:/config fabulinus:<version>`; `forgetool containers test --image fabulinus:<version> --config ./apps/fabulinus/container-test.yaml`. Readiness signal: UNVERIFIED (unknown logs).

## 12. PR checklist

No PR should be opened. If it is ever unblocked: branch `feat/add-fabulinus`, commit and PR title `feat(fabulinus): add new container`, PR template filled in, Notes section containing `🤖 This PR is AI generated.`, and tell the user about the CLA (https://cla-assistant.io/trueforge-org/containerforge; only the user can sign it). Untested: everything (nothing was built or run).

## Fix attempt (2026-11-28)

Result: no container files written. Tried: re-read the plan and context, searched the web for a public source or redistributable artifact. Findings: the `titanml/takeoff-community` repo is archived and holds docs only; the server source is not public (public pieces are only Apache-2.0 integrations such as `takeoff-haystack` and `takeoff-dataiku`); an early announcement said the server is free for personal and academic use and commercial use needs contacting TitanML (restricted, not an OSS licence); the current product is `tytn/takeoff-pro`, which needs a licence key at first launch. The only runnable artifact is the closed `tytn/fabulinus` image (last push 2023-11-17, root, amd64 only), and without a licence grant a Dockerfile could only copy from it or invent a server, so any file would contain invented facts.

Needed to continue: a written redistribution grant from TitanML, or a public source plus licence for the fabulinus server (then the plan above applies). Otherwise close as won't port, or replace the chart's image with a maintained inference server (for example vLLM or llama.cpp).
