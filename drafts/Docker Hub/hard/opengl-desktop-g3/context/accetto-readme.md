# accetto/headless-drawing-g3 README

Source URL(s): https://github.com/accetto/headless-drawing-g3 (raw README) · fetched 2026-11-26

- G3 (version G3v8) headless Ubuntu 24.04 images: Xfce, TigerVNC, noVNC; Mesa3D, VirtualGL (OpenGL/GLES/WebGL); tools glxgears, es2tri, glmark2.
- Variants on Docker Hub: `accetto/ubuntu-vnc-xfce-opengl-g3` (build folder docker/xfce), blender, drawio, freecad, gimp, inkscape.
- Default user `headless:headless` 1001:1001 (since G3v6); UID/GID overridable at build and run time; sudo rights.
- Feature switches: FEATURES_NOVNC="0" (drops noVNC, -vnc tag suffix); FEATURES_FIREFOX_PLUS.
- Env defaults, run examples, shm and GPU notes: not in README; points to User Guide accetto.github.io/user-guide-g3 (not fetched).
- Developer build tools: builder.sh, ci-builder.sh, secrets.rc.
- License: MIT (per LICENSE file, Copyright 2021 accetto).
