target "docker-metadata-action" {}

variable "APP" {
  default = "slink"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=andrii-kryvoviaz/slink extractVersion=^v(?<version>.+)$ versioning=semver
  default = "1.14.6"
}

variable "CADDY_VERSION" {
  // renovate: datasource=github-releases depName=caddyserver/caddy
  default = "2.11.9"
}

variable "XCADDY_VERSION" {
  // renovate: datasource=github-releases depName=caddyserver/xcaddy
  default = "0.4.7"
}

variable "VALKEY_PACKAGE_VERSION" {
  // renovate: datasource=deb depName=valkey-server registryUrl=https://archive.ubuntu.com/ubuntu
  // UNVERIFIED: copied from apps/valkey, not checked against ubuntu 26.04 for this image
  default = "9.0.4-0ubuntu0.2"
}

// UNVERIFIED: AGPL-3.0 per README. The plan could not confirm -only or -or-later.
variable "LICENSE" {
  default = "AGPL-3.0-only"
}

variable "SOURCE" {
  default = "https://github.com/andrii-kryvoviaz/slink"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    CADDY_VERSION = "${CADDY_VERSION}"
    XCADDY_VERSION = "${XCADDY_VERSION}"
    VALKEY_PACKAGE_VERSION = "${VALKEY_PACKAGE_VERSION}"
  }
  labels = {
    "org.opencontainers.image.source" = "${SOURCE}"
    "org.opencontainers.image.licenses" = "${LICENSE}"
  }
}

target "image-local" {
  inherits = ["image"]
  output = ["type=docker"]
  tags = ["${APP}:${VERSION}"]
}

target "image-all" {
  inherits = ["image"]
  platforms = [
    "linux/amd64",
    "linux/arm64"
  ]
}
