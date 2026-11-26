# flightaware/piaware README (master)

Source URL: https://raw.githubusercontent.com/flightaware/piaware/master/README.md (fetched)

- What: forwards ADS-B receiver data to FlightAware; helpers piaware, piaware-config, piaware-status, faup1090, fa-mlat-client.
- License: "free and liberal BSD license" (variant not named).
- Platforms: Raspbian/Debian packages; source builder piaware_builder (github.com/flightaware/piaware_builder). This repo = part of package.
- Config: via piaware-config (file not named on page); restart after changes.
- Ports: 30005 (beast input from dump1090); 30104 (mlat return default; older 30004); 31003 example basestation mlat.
- No web/status port documented; status via piaware-status / systemctl status piaware.
- Connection: TLS TCP to FlightAware; mlat UDP.
- Service: piaware.service; log /var/log/piaware.log (weekly rotation).
