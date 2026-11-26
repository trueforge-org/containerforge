# PrusaSlicer README (prusa3d/PrusaSlicer)

Source: https://raw.githubusercontent.com/prusa3d/PrusaSlicer/master/README.md (from https://github.com/prusa3d/PrusaSlicer), fetched 2026-11-26

## What it is
- Slicer for FDM and mSLA 3D printers; C++20, CMake build; originally based on Slic3r.

## Installation (upstream)
- Recommended: prusa3d.com/prusaslicer download.
- Windows/macOS: GitHub releases page.
- Linux: "currently distributed exclusively through Flathub" (com.prusa3d.PrusaSlicer).
- Source build: doc/Build.md (not fetched).

## Runtime notes
- Has CLI mode (runs without GUI) for automation.
- Stack: wxWidgets GUI, OpenGL UI (Yoga, Dear ImGui), Clipper, Eigen.

## Gotchas
- README contradicts the Dockerfile's assumption of a GitHub AppImage asset on Linux (Flathub is the stated Linux channel). Release assets not checked.
