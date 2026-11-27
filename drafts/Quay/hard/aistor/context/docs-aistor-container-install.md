# docs.min.io/aistor/installation/container/install/

Source URL(s): https://docs.min.io/aistor/installation/container/install/ (fetched 2026-11-27, WebFetch summary)

## Image
- quay.io/minio/aistor/minio (docs example tag: latest; chart pins a dated tag RELEASE.2026-09-19T17-05-25Z)

## Run (Docker or Podman)
```
docker run -dt \
  -p 9000:9000 -p 9001:9001 \
  -v $HOME/minio/data:/mnt/data \
  -v $HOME/minio/minio.license:/minio.license \
  -v $HOME/minio/certs:/etc/minio/certs \
  --name "aistor-server" \
  quay.io/minio/aistor/minio:latest minio server /mnt/data \
  --license /minio.license \
  --certs-dir /etc/minio/certs
```

## Ports
- 9000 S3 API; 9001 Console UI.

## Volumes
- /mnt/data (object data, doc example) ; /minio.license (license file) ; /etc/minio/certs (TLS, optional).
- Note: the chart mounts data at /data (MINIO_VOLUMES=/data), the doc example uses /mnt/data.

## License
- A license is required to run; production needs an active one.
- Free tier license from pricing page: single compute resource, one or more drives, no support.
- Pass via --license /minio.license.

## Env vars
- None set in the docs commands. Page states default login minioadmin:minioadmin.

## Not covered
- UID/user, healthcheck, compose or k8s snippets.

## Client
- mc from https://dl.min.io/aistor/mc/release/linux-amd64/mc (or linux-arm64).
