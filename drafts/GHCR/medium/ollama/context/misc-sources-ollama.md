# Misc sources: uv, openwebui.com

Source URL(s) + date:
- https://astral.sh/uv (2026-11-27): returned the GitHub page for astral-sh/uv (site redirect). Content: "An extremely fast Python package and project manager, written in Rust."
- https://openwebui.com (2026-11-27): marketing page "Open WebUI: Self-Hosted AI Platform". Product: "Private AI for your organization. A complete workspace for agents on your own machine."

Relevance to build:
- uv: Open WebUI Dockerfile pins `ghcr.io/astral-sh/uv:0.12.10` as a build mount and installs locked requirements with `uv pip install --system --no-deps --require-hashes`.
- openwebui.com: no build facts.
