# docs.influxdata.com: Chronograf installation

Source URL(s) + fetch date:
- https://docs.influxdata.com/chronograf/latest/introduction/installation/ (fetched 2026-11-26)

## Install methods
- macOS tar archive: `tar zxvf chronograf-1.11.8_darwin_amd64.tar.gz`
- Ubuntu & Debian: `sudo dpkg -i chronograf_1.11.8_amd64.deb`
- RedHat & CentOS: `sudo yum localinstall chronograf-1.11.8.x86_64.rpm`
- Packages come from https://www.influxdata.com/downloads/ (InfluxDB 1.x Open Source section, then Chronograf).

## Startup
- Binary: `chronograf`. For deb/rpm packages: `service chronograf start` or `systemctl start chronograf`.

## Ports
- UI at http://localhost:8888. Related defaults: InfluxDB 8086, Kapacitor 9092.

## Data directory
- Datastore file `chronograf-v1.db`. For tar installs, keep it outside the launch directory so config and dashboards persist across versions. No default data path is stated on this page.

## System requirements
None listed beyond the OS package choice. Kapacitor is optional.

## Setup after start (UI, not relevant to build)
Add a source with Connection String (InfluxDB host and port), optional name and credentials; default Telegraf DB name `telegraf`. Kapacitor connection uses port 9092.

## Gotchas
- Page shows v1.11.8 examples; ContainerForge plan pins 1.11.7.
