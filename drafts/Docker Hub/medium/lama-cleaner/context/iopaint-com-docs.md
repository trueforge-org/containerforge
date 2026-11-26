# IOPaint docs (www.iopaint.com): intro, install, model download

## Source URL(s) + date
- https://www.iopaint.com (2026-11-26)
- Merged follow-ups: https://www.iopaint.com/install (2026-11-26), https://www.iopaint.com/install/download_model (2026-11-26)
- Not fetched (budget): /install/try_online, /install/windows_1click_installer

## What it is
- Free, open-source, self-hostable inpainting/outpainting tool. Successor of lama-cleaner (see lama-cleaner-docs-vercel.md).
- Models selectable: LaMa, PowerPaint, AnyText, PaintByExample, etc.

## Install steps (docs /install)
1. Optional GPU PyTorch: `pip3 install torch==2.1.2 torchvision==0.16.2 --index-url https://download.pytorch.org/whl/cu118` (NVIDIA) or `.../rocm5.6` (AMD, Linux only). Skip for CPU.
2. `pip3 install iopaint`
3. `iopaint start --model=lama --device=cpu --port=8080` (serves http://localhost:8080)
- `iopaint start --help` lists all flags. `iopaint start-web-config --config-file iopaint-config.json` for gradio config; `iopaint start --config iopaint-config.json` to run it.

## Models / download (docs /install/download_model)
- Models download automatically at service start.
- Manual download dir for erase models: `~/.cache/torch/hub/checkpoints/` (LaMa, LDM, ZITS, MAT, FcF, MIGAN from GitHub links).
- Custom dir: CLI arg `--model-dir=xxxx`.
- Diffusion models: `~/.cache/huggingface/hub/` by default. Mirror: `HF_ENDPOINT=https://hf-mirror.com iopaint start`.

## Gotchas
- No container-specific info in these pages.
- Docs list a Windows 1-click installer and an "Try Online" page (not fetched).
