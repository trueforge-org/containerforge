# trueforge-org/truecharts charts/stable/blog values.yaml

Source: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/blog/values.yaml (raw variant of listed chart folder URL; fetched 2026-11-26)

- Image: docker.io/m1k1o/blog, tag `latest` pinned by digest (IfNotPresent)
- Service main: container port 80, service port 10111, protocol http
- Env: TITLE "Blog", NAME, LANG "en", DB type postgres, DB port 5432, Postgres user/db "blog" (templated), password from secret, host from secret; NICK; BLOG_PASS from secret
- Persistence: `data` volume at /var/www/html/data
- Runs as root (UID/GID 0); readOnlyRootFilesystem and nonRoot disabled; HTTP probes on "/"
- PostgreSQL dependency enabled

## Chart.yaml (added 2026-11-26)
Source: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/blog/Chart.yaml
- name blog; version 17.0.1; appVersion `latest`; type application; deprecated false
- description: Lightweight self-hosted facebook-styled PHP blog.
- kubeVersion >=1.33.0-0; min helm 3.14; max helm 4.1; max k8s 1.35.0
- dependency: common 32.8.5 (oci://oci.trueforge.org/truecharts)
- sources: m1k1o/blog, nicholaswilde/docker-blog, truecharts chart folder, hub m1k1o/blog
