# android-8-0 — implementation plan
> Source: ./draft.md · Target: apps/android-8-0/ · Difficulty: hard (recommend NOT porting) · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | Chart tag `latest` of `ulisses1478/docker-android`. Docker Hub shows a single `latest` tag, amd64, last pushed 2019-05-29. There is no version to track. |
| Renovate | None possible for the image tag. The wrapped project `budtmo/docker-android` has releases (latest seen: `v3.9.0-p2`), but the 8.0 image is built from `butomo1989/docker-android-x86-8.0`, last updated 2019-01-16 on Docker Hub, and is not produced by current releases. |
| License | The wrapper `ulisses1478/docker-android` has no licence found (UNVERIFIED). The wrapped `budtmo/docker-android` `LICENSE.md` is "Custom Apache 2.0": Apache-2.0 plus a fork clause (remove its Google Form ID or stop usage gathering) and a data-processing agreement that collects non-PII usage data. The Android SDK and emulator carry Google's own licences. SPDX for the bake file is therefore not a clean single id: UNVERIFIED. |
| Source URL | https://github.com/ulisses1478/docker-android (wrapper), https://github.com/budtmo/docker-android (upstream), https://source.android.com |
| Downloads | None usable. The wrapper's Dockerfile is a single line: `FROM butomo1989/docker-android-x86-8.0`. All content (SDK, system image, noVNC, Appium) comes from that opaque 2019 base, not from URLs we can fetch per architecture. |
| Checksum | None. |
| Upstream Dockerfile reviewed | `ulisses1478/docker-android/Dockerfile` (one `FROM` line). The budtmo README at master documents the modern run line: `docker run -d -p 6080:6080 -e EMULATOR_DEVICE="Samsung Galaxy S10" -e WEB_VNC=true --device /dev/kvm budtmo/docker-android:emulator_11.0`, with noVNC on `6080`. |
| Ports | `6080` (noVNC) is verified for current budtmo images. `5555` (adb) and `5900` (VNC) from the draft are UNVERIFIED for the 2019 8.0 image. |
| Env vars | Current budtmo names `EMULATOR_DEVICE`, `WEB_VNC` are verified in its README; whether the 2019 8.0 base reads them is UNVERIFIED. |
| Hardware | Needs `/dev/kvm` (README: `--device /dev/kvm`, `kvm-ok`). Needs an x86 host; Android x86 guest images do not run on arm64. |

## 2. Target layout

If it is ever built (not recommended, see section 10):

```
apps/android-8-0/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```

No `defaults/`, `etc/`, `health/` or `root/` until a real build proves they are needed. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`

Reason: the draft says "ubuntu alone". A source-built image would install JDK, Android SDK command-line tools, the emulator, an x86 system image, a VNC server and noVNC on top. Closest sibling for a heavyweight download-and-install image: `apps/steamcmd` (large payload fetched at build/first run) and for Java: `apps/nzbhydra2`. No sibling does emulation.

## 4. Dockerfile

Only an outline is credible, since no upstream recipe exists for the 8.0 image:

1. `ARG VERSION` (Android API level, e.g. `26` for 8.0), `ARG TARGETARCH`; `RUN test "${TARGETARCH}" = "amd64"`.
2. `USER root`: install `openjdk` (check the Android `sdkmanager` Java requirement, UNVERIFIED), `unzip`, `libpulse0`, `libgl1`, `xvfb`, `x11vnc`, `novnc`, `websockify`, `supervisor`-free equivalents (see section 7). Verify each against the base before adding.
3. Fetch the Android command-line tools from `https://dl.google.com/android/repository/` (exact filename and checksum UNVERIFIED: the Google repository XML lists a sha1 per archive; fetch it at plan-execution time) and extract to `/app/android-sdk`.
4. Use `sdkmanager` with `--sdk_root=/app/android-sdk` to install `platform-tools`, `emulator` and `system-images;android-26;default;x86_64` (package id UNVERIFIED). This requires accepting the Android SDK licence; ship the licence texts to `/usr/share/licenses/android-8-0/`.
5. Create the AVD at build time in `/app/avd` (read-only at runtime) or at first start in `/config/avd`; `ANDROID_AVD_HOME`/`ANDROID_USER_HOME` must point to writable `/config`, `HOME=/config`, caches `/tmp`.
6. `chown -R apps:apps /app`, clean apt lists, `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 6080 5555`, `VOLUME /config`.

The image would be multiple GB; the budtmo upstream is likewise very large.

## 5. docker-bake.hcl

- `APP = "android-8-0"`, `SOURCE = "https://github.com/budtmo/docker-android/"` (or the wrapper, decide at port time), `LICENSE`: UNVERIFIED (Apache-2.0 for the scripts, Google licences for SDK and emulator; the image must carry the licence of the software in it, so a multi-licence string such as `Apache-2.0 AND LicenseRef-Android-SDK` needs maintainer sign-off).
- `VERSION` default `"8.0.0"` with `// renovate: datasource=github-releases depName=budtmo/docker-android versioning=loose` only if the Dockerfile really builds from budtmo releases; otherwise there is nothing to track and renovate must be omitted with a comment. UNVERIFIED which applies.
- Standard targets; `image-all.platforms = ["linux/amd64"]` only.
- `docker buildx bake --print` must pass.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/budtmo/docker-android/"
ports:
  - {port: 6080, protocol: tcp, required: false}
env:
  - {name: TZ, default: "Etc/UTC", required: false}
  - {name: EMULATOR_DEVICE, default: "Nexus 5", required: false}   # UNVERIFIED default; verified only as a name in current budtmo README
  - {name: WEB_VNC, default: "true", required: false}
volumes:
  - {path: /config, required: true}
```

Only 6080 is listed because the other ports are UNVERIFIED for this image. No dependencies. Env names must be confirmed against the script that `start.sh` writes (they are not read by anything until we write that script).

## 7. start.sh

Not writable from verified facts. Intended shape:

1. `mkdir -p /config/avd /tmp/.X11-unix`; create the AVD only if `/config/avd/<name>.avd` is missing.
2. Start `Xvfb :0` (socket in `/tmp/.X11-unix`), a VNC server on localhost, and `websockify` for noVNC on `0.0.0.0:6080`, as background children with `wait -n` so the container exits if one dies.
3. `exec /app/android-sdk/emulator/emulator -avd <name> -no-audio -gpu swiftshader_indirect -no-snapshot-save` (flags UNVERIFIED; check `emulator -help`). Fail with a clear log line when `/dev/kvm` is absent or not writable by the `apps` user (group `kvm` membership via `--group-add`).
4. Bind noVNC to all interfaces; keep adb on localhost unless an env var opts in (adb has no authentication).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 300
tcp:
- port: '6080'
filePaths:
- /app/android-sdk/emulator/emulator
- /app/android-sdk/platform-tools/adb
```

- The test has no `/dev/kvm`, so the emulator itself cannot boot there; the noVNC front (6080) and the binary paths are what can be asserted. `timeoutSeconds` is a placeholder (copy `apps/steamcmd`'s value when it is built).
- Do not claim a functional test of Android boot; it must be run by hand on a KVM host (section 11).

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `~/.android`, AVD dirs, emulator snapshots | `HOME=/config`, `ANDROID_AVD_HOME=/config/avd`, snapshots off or in `/config`. |
| Xvfb/X11 sockets, VNC and noVNC temp files | `/tmp`. |
| SDK install location | `/app/android-sdk` (read-only; `sdkmanager` must not run at runtime). |
| Chart `runAsUser: 0` | Run as `apps`; the user needs access to `/dev/kvm` via a supplementary group (`kvm`), not root. |

The draft expects privileged/KVM passthrough: device passthrough (`--device /dev/kvm`) is enough, `privileged: true` should not be needed (UNVERIFIED). Read-only rootfs is plausible only if the AVD lives in `/config`.

## 10. Risks, caveats and open questions

- Recommendation: do not port. The 8.0 image is a 2019, unversioned, opaque base with no verifiable Dockerfile, ports or env contract; the wrapper has no licence found.
- Needs `/dev/kvm` and an x86 host: no arm64, no hosts without nested virtualisation (draft caveat, confirmed by the upstream README).
- Licensing is mixed: budtmo's "Custom Apache 2.0" includes a data-collection agreement, and Google SDK/emulator/system images have their own terms. A redistributed multi-GB image needs legal review.
- Android 8.0 is long out of support; security posture is poor.
- Image would be very large and first start slow (draft caveat).
- If a modern equivalent is wanted, the maintainers should instead consider a `budtmo/docker-android`-based plan with a current Android version; that is a different draft.

## 11. Build and test steps

Run from the repo root, one app only, in this order (per `build-test-protocol.instructions.md`):

```sh
cd apps/android-8-0
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name android-8-0-probe --read-only --tmpfs /tmp \
  -v android-8-0-probe-config:/config android-8-0:<VERSION>
docker logs -f android-8-0-probe     # without /dev/kvm expect a clear "KVM not available" message and the container still serving noVNC; do not treat that as a pass for emulator boot
# on a KVM host only:
docker run --rm -d --name android-8-0-kvm --read-only --tmpfs /tmp --device /dev/kvm --group-add kvm \
  -v android-8-0-probe-config:/config -p 6080:6080 android-8-0:<VERSION>
cd ../.. && forgetool containers test --image android-8-0:<VERSION> --config ./apps/android-8-0/container-test.yaml
docker rm -f android-8-0-probe android-8-0-kvm; docker volume rm android-8-0-probe-config
```

Fresh volume per round; round limit 10. Expected readiness signal on a KVM host: emulator log line `emulator: ... boot completed` (wording UNVERIFIED) and noVNC page loading on 6080.

## 12. PR checklist

- [ ] Get a go/no-go from the maintainers first (section 10); this port is not recommended.
- [ ] Branch `feat/add-android-8-0`, commit and PR title `feat(android-8-0): add new container`, target `main`.
- [ ] PR body uses `.github/PULL_REQUEST_TEMPLATE.md`; only tick boxes that apply.
- [ ] Notes section contains `🤖 This PR is AI generated.`
- [ ] Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign it).
- [ ] `docker buildx bake --print` passes; `ARG VERSION` equals the bake default; final `USER apps`; `COPY --chmod=0755 . /` kept.
- [ ] Untested at plan time: everything. No build, no KVM run, no arm64 (unsupported), ports 5555 and 5900 unverified, licence unresolved.
- [ ] No files outside `apps/android-8-0/`; no `root/`; no secrets.
