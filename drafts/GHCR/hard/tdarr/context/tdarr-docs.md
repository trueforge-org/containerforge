# Tdarr docs (docs.tdarr.io)
Sources: https://docs.tdarr.io/docs/installation/docker/run-compose (fetched 2026-11-27); https://docs.tdarr.io (root redirects to Tdarr docs, no content)

## Images (run-compose page)
- amd64: ghcr.io/haveagitgat/tdarr (server + internal node), ghcr.io/haveagitgat/tdarr_node (node only)
- armv8 variants exist (Raspberry Pi, Apple M1)
- --privileged may be needed on Raspberry Pi
- Auth on by default: every node (including internal) needs an apiKey (see Authentication page)
- NVIDIA: `--gpus=all`; `--runtime=nvidia` only if docker info lists it

## tdarr container example (run-compose)
- Volumes: /app/server, /app/configs, /app/logs, /media, /temp (transcode cache)
- Env: serverIP=0.0.0.0, serverPort=8266, webUIPort=8265, internalNode=true, inContainer=true, ffmpegVersion=7, nodeName=MyInternalNode, auth=true, apiKey="", openBrowser=true, maxLogSizeMB=10, cronPluginUpdate="", TZ, PUID=1000, PGID=1000, NVIDIA_DRIVER_CAPABILITIES=all, NVIDIA_VISIBLE_DEVICES=all
- Ports published: 8265, 8266; --device=/dev/dri:/dev/dri
## tdarr_node example
- Volumes: /app/configs, /app/logs, /media, /temp
- Env: nodeName, serverIP, serverPort=8266, inContainer=true, ffmpegVersion=7, nodeType=mapped, priority=-1, apiKey, maxLogSizeMB=10, pollInterval=2000, startPaused=false, transcodegpuWorkers, transcodecpuWorkers

## Failures in this file
- Configuration Variables page (docs.tdarr.io/docs/configuration/variables): no usable content extracted
