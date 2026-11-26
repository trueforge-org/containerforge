# mend-renovate — implementation plan
> Source: ./draft.md · Target: apps/mend-renovate/ · Difficulty: very-hard · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | Draft: `ghcr.io/mend/renovate-ce:15.12.0`. Manifest index for `15.12.0` fetched anonymously (HTTP 200): https://ghcr.io/v2/mend/renovate-ce/manifests/15.12.0. Whether 15.12.0 is the latest stable tag is UNVERIFIED (tag list was not fetched). |
| Architectures (manifest) | The index lists `linux/amd64` (`sha256:2b236bfd19b1e7a9537e7232e043eb2c547cf0187f4a79ae2bb7934dc72c9ed0`) and `linux/arm64` (`sha256:b83e0889d3a0ac55e3ec42856ac0f403639108f84fbd2fcd46d2462ba28b863f`). This contradicts the draft's "arm64 not available"; manifest presence is confirmed, runtime use on arm64 is UNVERIFIED. |
| Renovate | `datasource=docker depName=ghcr.io/mend/renovate-ce versioning=docker` (proposed; the image is the only versionable artifact). |
| License | Proprietary. `README.md` of https://github.com/mend/renovate-ce-ee: use is bound by Mend's Terms of Service, and a license key is requested via https://www.mend.io/renovate-community/. The docs in that repo are MIT. There is no SPDX for the image. |
| Source | No public source code. https://github.com/mend/renovate-ce-ee holds documentation, release notes and issues only. |
| Dockerfile | None public (the README says the image is distributed via GHCR under the `mend` namespace). |
| Redistribution | Restricted by the ToS. Mirroring the image into `ghcr.io/trueforge-org` or COPY-ing from it is not confirmed as permitted. |
| Ports, env vars, data paths | UNVERIFIED: `docs/configuration-options.md` was not fetched. The draft's `8080/http` is unconfirmed. |
| Open-source substitute | npm `renovate` 44.262.2 (registry lists both `MIT` and `AGPL-3.0-only`; the authoritative licence is UNVERIFIED). Not the same product. |

## 2. Target layout

Not applicable: the port is blocked (section 10). If unblocked, the layout would be `apps/mend-renovate/` with `Dockerfile`, `docker-bake.hcl`, `settings.yaml`, `container-test.yaml`, and `start.sh`. No `defaults/`, `etc/` or `health/` unless the config file needs seeding.

## 3. Base image

Not applicable while blocked. If the open-source substitute route were taken, the base would be `ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5` (Node runtime). This substitute is not the same product and is not recommended.

## 4. Dockerfile

Not applicable while blocked. Copying the closed-source image with `COPY --from=ghcr.io/mend/renovate-ce:15.12.0` is the only route that keeps the product itself. It depends on the ToS, a license key, and an arch-specific build, so it needs a decision before any Dockerfile is written. Do not write a Dockerfile until the licence question is answered.

## 5. docker-bake.hcl

Not applicable while blocked. When unblocked, the variables would be `APP=mend-renovate`, `VERSION=15.12.0` (with the renovate annotation from section 1), `LICENSE` set to the ToS-based value (not an SPDX identifier, UNVERIFIED for this repo's convention), `SOURCE=https://github.com/mend/renovate-ce-ee`.

## 6. settings.yaml

Not applicable while blocked. Ports and env vars are unknown (UNVERIFIED, see section 1). Do not list any until the configuration-options doc has been read.

## 7. start.sh

Not applicable while blocked. The upstream image's own entrypoint is not known (UNVERIFIED). Do not write a `start.sh` that guesses it.

## 8. container-test.yaml

Not applicable while blocked. Any `tcp` or `http` probe needs a confirmed port (section 1). The probe for the eventual port must be added with the config file.

## 9. Rootless and read-only-rootfs adaptations

Not applicable while blocked. The chart sets `runAsUser 0`, `runAsNonRoot false` and `readOnlyRootFilesystem false` (draft, from charts/stable/mend-renovate values). Whether the closed image runs as non-root or on a read-only rootfs is UNVERIFIED and cannot be checked without a pull and a licence.

## 10. Risks, caveats and open questions

- Blocker 1 (licence): the image is closed-source with a ToS that restricts redistribution. The Renovate CE docs say a licence key is needed. The draft's "terms restrict redistribution" is consistent with the README.
- Blocker 2 (arm64): the manifest lists arm64, which contradicts the draft. A decision depends on whether the arm64 build runs, which is UNVERIFIED.
- Existing sibling: `apps/renovate` already ships the open-source Renovate (`docker.io/renovate/renovate:${VERSION}-full`, bake VERSION 44.263.5, AGPL-3.0-or-later), so the substitute route would duplicate it.
- Blocker 3 (substitute): the open-source npm `renovate` is a different product. Using it would mean a different app, not a port of `renovate-ce`.
- The image's ports, env vars, entrypoint, config path and volumes are unconfirmed.
- Draft caveats kept: a licence or account may be needed to pull or run (inferred; the manifest pull was anonymous, but running needs a licence key).

Decision needed before any work: whether ContainerForge may ship a copy of this image. Until that is answered, the status is blocked.

## 11. Build and test steps

Not applicable while blocked. No build or run is attempted. When unblocked, follow the build and test protocol (bake print, build amd64, run on `--read-only --tmpfs /tmp` with an empty `/config`, forgetool test).

## 12. PR checklist

Not applicable while blocked: no PR is opened.
When unblocked: branch `feat/add-mend-renovate`, commit `feat(mend-renovate): add new container`, PR template filled in, `🤖 This PR is AI generated.` in Notes, CLA notice (https://cla-assistant.io/trueforge-org/containerforge; only the user can sign), honest list of what is untested (the closed image was not built or run).
