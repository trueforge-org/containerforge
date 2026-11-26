# github.com/codeproject/CodeProject.AI-Server (repo README and releases)

Source URL(s) + fetch date:
- https://raw.githubusercontent.com/codeproject/CodeProject.AI-Server/master/README.md · fetched 2026-11-26
- https://github.com/codeproject/CodeProject.AI-Server/releases · fetched 2026-11-26
- https://github.com/codeproject/CodeProject.AI-Server (repo page, via the above) · fetched 2026-11-26

## What it is
Self-hosted AI microserver: REST API plus backend analysis services; source included. Modules listed: generative AI (LLMs, text-to-image, multimodal), object detection (incl. custom), face detection and recognition, scene recognition, background removal/blur, resolution enhancement, text summarisation, sentiment, sound classification. The README does not say which modules are installed by default.

## Install methods
Windows, macOS (Intel and Apple Silicon), Ubuntu/Debian, Raspberry Pi arm64, Docker. README points to an installer; Docker has a separate guide (no commands on the README). Dev install: clone repo, run setup script in `/devops/install`; Visual Studio 2019+ or VS Code.

## Platforms and hardware
- x64 Windows, macOS Intel, macOS arm64, Ubuntu/Debian, Raspberry Pi arm64.
- Hardware per module: CPU everywhere; DirectML (Windows); CUDA (Windows and Linux); Apple Silicon GPUs; RockChip NPUs; Coral.AI TPUs.
- Stack badges: .NET 9 and Python.

## Licence
SSPL (badge); "Open Source" badge also shown.

## Version / releases
- Latest release **v2.9.5**, 11 Dec. Previous: v2.9.4 (04 Dec), v2.8.1 (05 Sep), v2.6.5 (27 May). Years not shown on the page. Each release shows "Assets 2"; the asset names did not load.
- 2.9 release notes (README): .NET 9, Ubuntu 24.10 support, CUDA 12 improvements, Windows installer fix when wget is missing.

## Module install behaviour
README does not state whether module installs need internet. The docs say modules are installed from the dashboard at runtime.

## Gotchas
- The page mentions "I'll add this to the docs:", an editorial remark, not a project instruction.
