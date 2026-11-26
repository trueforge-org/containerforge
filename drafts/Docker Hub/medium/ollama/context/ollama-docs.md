# Ollama docs: Docker page and FAQ (docs.ollama.com)

## Source URL(s) + date
- https://docs.ollama.com/docker (2026-11-26)
- https://docs.ollama.com/faq (follow-up, 2026-11-26)

## Docker page (run commands)
- Image `ollama/ollama`, data volume `ollama:/root/.ollama`, port `11434:11434`.
- Nvidia: `--gpus=all`. AMD: use tag `ollama/ollama:rocm` (enabled by default when GPU device accessible).
- ROCm/Vulkan options: `OLLAMA_VULKAN=0` mentioned.

## FAQ env vars (names mentioned)
| Var | Default / meaning (from FAQ) |
| --- | --- |
| OLLAMA_HOST | Bind address. Default `127.0.0.1:11434` (FAQ: "Ollama binds 127.0.0.1 port 11434 by default") |
| OLLAMA_MODELS | Model directory. macOS default `~/.ollama/models`; Linux default `/usr/share/ollama/.ollama/models` |
| OLLAMA_KEEP_ALIVE | How long models stay loaded |
| OLLAMA_CONTEXT_LENGTH | Default context window (example 8192) |
| OLLAMA_ORIGINS | CORS origins |
| OLLAMA_MAX_QUEUE, OLLAMA_NUM_PARALLEL, OLLAMA_MAX_LOADED_MODELS | Concurrency |
| OLLAMA_FLASH_ATTENTION, OLLAMA_KV_CACHE_TYPE | Inference options |
| OLLAMA_CHANNEL | Release channel |
| OLLAMA_NO_CLOUD | Disable cloud features |

- Linux key path (FAQ): `/usr/share/ollama/.ollama/id_ed25519.pub`.

## Gotchas
- FAQ gives Linux default models path under `/usr/share/ollama/.ollama/models`. The plan assumes `$HOME/.ollama` (HOME=/config). Set `OLLAMA_MODELS` explicitly if `$HOME` is not used.
- Docs site is Mintlify (JS-rendered); facts taken from text in the HTML.
