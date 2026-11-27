# GitHub: cvarelaruiz/owi2plex README (upstream tool)
Source URL(s): https://raw.githubusercontent.com/cvarelaruiz/owi2plex/master/README.md (fetched 2026-11-27)

- Exporter of EPG from OpenWebif to XMLTV for Plex
- Dependencies: Python 3.7; Enigma2 plugins OpenWebif Server and HRTunerProxy
- Install: `pip install owi2plex`
- CLI flags: -b bouquet, -u user, -p password, -h host, -P port (int), -o output file, -c continuous numbering, -l list bouquets, -V version, -O category override YAML, -d debug
- Example: `owi2plex -b TV -h 192.168.0.150 -o /tmp/epg.xml`
- No built-in scheduling (use cron); takes about 45 s for 100+ channels
