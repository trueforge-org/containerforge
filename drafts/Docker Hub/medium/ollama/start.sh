#!/usr/bin/env bash

mkdir -p /config/models

# OLLAMA_HOST is read by the binary. Models go to OLLAMA_MODELS (/config/models).
exec /app/ollama/bin/ollama serve
