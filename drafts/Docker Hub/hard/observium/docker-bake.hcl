target "docker-metadata-action" {}

variable "APP" {
  default = "observium"
}

variable "VERSION" {
  // UNVERIFIED: no renovate datasource tracks Observium CE (unversioned "latest" tarball). Needs a maintainer-added customDatasource; otherwise bump by hand and update OBSERVIUM_SHA256 in the Dockerfile.
  // renovate: datasource=custom.observium depName=observium-community versioning=loose
  default = "26.1"
}

variable "LICENSE" {
  // UNVERIFIED: Observium License 1.0 (LICENSE.COMMUNITY in the tarball), not an OSI license; SPDX id to be confirmed. Redistribution question open (see PR notes).
  default = "LicenseRef-Observium-1.0"
}

variable "SOURCE" {
  default = "https://www.observium.org/"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
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
