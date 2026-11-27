# mymediaalexa.com/home/docker

Source URL(s): https://www.mymediaalexa.com/home/docker (fetched 2026-11-27; one fetch + one grep pass)

## Docker facts (vendor page)
- Image: bizmodeller/mymediaforalexa; "Docker support is in beta only"
- Platforms: x64 / armhf Linux, any device that runs Docker (e.g. supported NAS)
- Ports: tcp/52050 and tcp/52051, must be mapped to the same host ports (My Media advertises its IP:port to Alexa; NAT mapping is not usable)
- Volumes to remap:
  - /datadir: My Media settings, watch folders, DB of indexed files (stateful)
  - /medialibrary: music library (read to stream)
- Example run (vendor):
  `docker run -d -p 52050:52050 -p 52051:52051 -v ~/Music:/medialibrary -v ~/.MyMediaForAlexa:/datadir bizmodeller/mymediaforalexa`
- Access URL example: http://<host_ip>:52051
- Dirs must be created on the host first
- Page also loads Google Analytics and Paddle scripts (not relevant to build)
