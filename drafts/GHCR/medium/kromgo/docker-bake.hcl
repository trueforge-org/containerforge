target "docker-metadata-action" {}

variable "APP" {
  default = "kromgo"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=home-operations/kromgo versioning=semver
  default = "0.16.4"
}

variable "PNPM_VERSION" {
  // UNVERIFIED: take the value from upstream Dockerfile ARG PNPM_VERSION, then add a renovate annotation
  default = ""
}

variable "KROMGO_SHA256" {
  // UNVERIFIED: sha256 of https://github.com/home-operations/kromgo/archive/refs/tags/<VERSION>.tar.gz, computed once
  default = ""
}

variable "LICENSE" {
  // UNVERIFIED: confirm -only or -or-later against the LICENSE file
  default = "AGPL-3.0"
}

variable "SOURCE" {
  default = "https://github.com/home-operations/kromgo"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    PNPM_VERSION = "${PNPM_VERSION}"
    KROMGO_SHA256 = "${KROMGO_SHA256}"
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
