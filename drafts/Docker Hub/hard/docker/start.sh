#!/usr/bin/env bash
set -euo pipefail

# Data root and certs live in /config. The runtime dir lives in /tmp (read-only rootfs).
mkdir -p /config/docker-data /config/certs
mkdir -p -m 0700 /tmp/run
export XDG_RUNTIME_DIR=/tmp/run

# Create the CA, server and client certificates once. Layout follows upstream docker-library:
# ca/, server/ and client/ subdirectories. The keys are never regenerated while they exist.
gen_certs() {
  local dir="$1"
  if [[ -s "${dir}/server/cert.pem" && -s "${dir}/client/cert.pem" ]]; then
    return 0
  fi
  local san="IP:127.0.0.1,DNS:localhost"
  if [[ -n "${DOCKER_TLS_SAN:-}" ]]; then
    san="${san},${DOCKER_TLS_SAN}"
  fi
  mkdir -p "${dir}/ca" "${dir}/server" "${dir}/client"
  (
    umask 077
    cd "${dir}"
    openssl genrsa -out ca/key.pem 4096
    openssl req -new -x509 -days 365 -sha256 -key ca/key.pem -subj "/CN=docker-ca" -out ca/ca.pem

    openssl genrsa -out server/key.pem 4096
    openssl req -new -key server/key.pem -subj "/CN=docker-server" -out server/csr.pem
    printf 'subjectAltName=%s\nextendedKeyUsage=serverAuth\n' "${san}" > server/extfile.cnf
    openssl x509 -req -days 365 -sha256 -in server/csr.pem -CA ca/ca.pem -CAkey ca/key.pem \
      -CAcreateserial -out server/cert.pem -extfile server/extfile.cnf

    openssl genrsa -out client/key.pem 4096
    openssl req -new -key client/key.pem -subj "/CN=docker-client" -out client/csr.pem
    printf 'extendedKeyUsage=clientAuth\n' > client/extfile.cnf
    openssl x509 -req -days 365 -sha256 -in client/csr.pem -CA ca/ca.pem -CAkey ca/key.pem \
      -CAcreateserial -out client/cert.pem -extfile client/extfile.cnf

    cp ca/ca.pem server/ca.pem
    cp ca/ca.pem client/ca.pem
    rm -f server/csr.pem server/extfile.cnf client/csr.pem client/extfile.cnf ca/ca.srl
  )
}

DOCKERD_ARGS=(--host=unix:///tmp/run/docker.sock)

if [[ -n "${DOCKER_TLS_CERTDIR:-}" ]]; then
  gen_certs "${DOCKER_TLS_CERTDIR}"
  DOCKERD_ARGS+=(
    --host=tcp://0.0.0.0:2376
    --tlsverify
    --tlscacert="${DOCKER_TLS_CERTDIR}/server/ca.pem"
    --tlscert="${DOCKER_TLS_CERTDIR}/server/cert.pem"
    --tlskey="${DOCKER_TLS_CERTDIR}/server/key.pem"
  )
  # rootlesskit forwards the TLS port out of its network namespace
  export DOCKERD_ROOTLESS_ROOTLESSKIT_FLAGS="${DOCKERD_ROOTLESS_ROOTLESSKIT_FLAGS:-} -p 0.0.0.0:2376:2376/tcp"
else
  echo "WARNING: DOCKER_TLS_CERTDIR is empty, so the Docker API is unauthenticated on tcp://0.0.0.0:2375" >&2
  DOCKERD_ARGS+=(--host=tcp://0.0.0.0:2375)
  export DOCKERD_ROOTLESS_ROOTLESSKIT_FLAGS="${DOCKERD_ROOTLESS_ROOTLESSKIT_FLAGS:-} -p 0.0.0.0:2375:2375/tcp"
fi

cd /config
# UNVERIFIED: exact flag set; the rootless script is shipped in the rootless extras tarball
exec dockerd-rootless.sh "${DOCKERD_ARGS[@]}" --data-root /config/docker-data
