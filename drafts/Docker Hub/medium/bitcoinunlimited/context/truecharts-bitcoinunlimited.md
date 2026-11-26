# trueforge-org/truecharts charts/stable/bitcoinunlimited

Source: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/bitcoinunlimited (fetched 2026-11-26)

## Facts
- Files: templates/, CHANGELOG.md, Chart.yaml, README.md, values.yaml, values.schema.json, icons
- Install: `helm install mychart oci://oci.trueforge.org/truecharts/bitcoinunlimited`
- Not maintained by upstream; issues go to TrueCharts tracker
- Templating from shared `charts/library/common`
- Image repo/tag, ports, env, persistence: NOT shown (values.yaml not rendered on page)

## Chart.yaml (added 2026-11-26)
Source: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/bitcoinunlimited/Chart.yaml
- name bitcoinunlimited; version 11.0.0; appVersion `latest`; type application; deprecated false
- kubeVersion >=1.33.0-0; min helm 3.14; max helm 4.1; max k8s 1.35.0
- dependency: common 32.8.5 (oci://oci.trueforge.org/truecharts)
- sources: truecharts chart folder, https://hub.docker.com/r/amacneil/bitcoinunlimited
- keywords: bitcoinunlimited, Network-Other; train stable
