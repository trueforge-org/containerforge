# cura-novnc: source context (fetched 2026-11-26)

## Sources fetched

| Source URL | Summary file |
| --- | --- |
| https://github.com/Ultimaker/Cura (releases/latest, README, LICENSE, wiki Getting-Started) | github-ultimaker-cura.md |
| https://github.com/Ultimaker/Cura/releases/latest | github-ultimaker-cura.md |
| https://raw.githubusercontent.com/Ultimaker/Cura/main/LICENSE | github-ultimaker-cura.md |
| https://github.com/Ultimaker/Cura/wiki/Getting-Started | github-ultimaker-cura.md |
| https://ultimaker.com/software/ultimaker-cura/ | ultimaker-cura-website.md |
| https://support.ultimaker.com/s/topic/0TO5b000000Q4udGAC/manuals (failed) | ultimaker-cura-website.md |
| https://github.com/helfrichmichael/cura-novnc/blob/master/Dockerfile | github-helfrichmichael-cura-novnc.md |
| https://hub.docker.com/r/mikeah/cura-novnc | dockerhub-mikeah-cura-novnc.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/cura-novnc (values.yaml) | truecharts-cura-novnc.md |

## Skipped URLs

| URL | Reason |
| --- | --- |
| https://cla-assistant.io/trueforge-org/containerforge | CLA link (never fetched) |
| https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu | containerforge base app link |
| https://github.com/Ultimaker/Cura/releases/download/5.8.1/UltiMaker-Cura-5.8.1-linux-X64.AppImage | direct binary (AppImage) download; pattern recorded (`UltiMaker-Cura-<version>-linux-X64.AppImage`) |
| https://github.com/Ultimaker/Cura/releases/download/${VERSION}/UltiMaker-Cura-${VERSION}-linux-X64.AppImage | direct binary download; same pattern |
| https://github.com/helfrichmichael/cura-novnc (repo root) | named only; Dockerfile fetched |
| http://localhost:3000 | localhost URL (not a source) |

## Fetch failures

- https://support.ultimaker.com/s/topic/0TO5b000000Q4udGAC/manuals: page shows a CSS error, no content.
- GitHub release asset list for 5.14.0: did not load.
- Not fetched (depth budget, not required by plan): Cura "Running Cura from Source" (system requirements) and "Cura Preferences and Settings Locations".

## plan.md corrections

None required. Checked and consistent with plan.md:
- Version 5.14.0 (05 Nov) is the latest release (github-ultimaker-cura.md).
- Linux is x64 AppImage only; arm64 has no AppImage (ultimaker-cura-website.md, github-ultimaker-cura.md), supporting the plan's apt-cura fallback question.
- Wrapper Dockerfile (debian bullseye, easy-novnc 1.1.0 on 8080, TigerVNC 5900, supervisord, openbox, `cura` user, AppRun sed, `usermod -aG dialout`, VOLUME `/home/cura/` and `/prints/`) matches plan section 1.

## Unverified (plan.md left as-is)

- Licence: LICENSE section 6 "or any later version" applies only when Cura specifies it; `LGPL-3.0-or-later` depends on Cura's per-file headers (not fetched).
- Arm64 `cura` apt package 5.0.0 (plan) — not checked here; the page only says Linux is x64.
- OpenGL 4.1+ requirement (plan section 10): not stated on any fetched page.
- `ghcr.io/trueforge-org/kasmvnc` digest and existence: not checked here (a containerforge repo check, not a web source).
- Env `QT_QPA_PLATFORM`, `LIBGL_ALWAYS_SOFTWARE`, `MESA_GL_VERSION_OVERRIDE` (plan section 4 step 6): not in any fetched source.
