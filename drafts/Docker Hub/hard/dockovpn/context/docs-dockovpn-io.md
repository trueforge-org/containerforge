# dockovpn.io (project site)

Source URL(s) + fetch date:
- https://dockovpn.io
- Fetched 2026-11-26

## What it is
- DockOvpn: "an out of the box dockerized OpenVPN server" that starts in about 2 seconds. Open source, code on GitHub. Page also promotes a separate paid hosted VPN service (HostedVPN), not part of this container.

## Run instructions (site)
```
docker run -it --rm --cap-add=NET_ADMIN -p 1194:1194/udp -p 80:8080/tcp \
  -e HOST_ADDR=$(curl -s https://api.ipify.org) --name dockovpn alekslitvinenk/openvpn
```
- Console prints a URL to fetch `client.ovpn`. Server shuts down after the config download.
- Note: the site's example sets HOST_ADDR to the public IP; the README advises against changing HOST_ADDR unless necessary.

## Compatible clients
- Windows: OpenVPN Connect. Mac: Tunnelblick or OpenVPN Connect. Linux: openvpn CLI.

## Gotchas
- Site example uses an external IP lookup service (api.ipify.org) in the run command; not a container dependency.
