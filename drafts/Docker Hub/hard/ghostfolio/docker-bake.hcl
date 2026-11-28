target "docker-metadata-action" {}

variable "APP" {
  default = "ghostfolio"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=ghostfolio/ghostfolio versioning=loose
  default = "3.101.0"
}

variable "LICENSE" {
  // UNVERIFIED: AGPL-3.0-only vs AGPL-3.0-or-later. Confirm in the repo LICENSE header.
  default = "AGPL-3.0-only"
}

variable "SOURCE" {
  default = "https://github.com/ghostfolio/ghostfolio"
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
