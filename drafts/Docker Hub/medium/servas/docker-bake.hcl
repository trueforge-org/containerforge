target "docker-metadata-action" {}

variable "APP" {
  default = "servas"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=beromir/Servas versioning=semver
  default = "1.2.0"
}

variable "LICENSE" {
  // UNVERIFIED: GitHub reports GPL-3.0; confirm the SPDX variant from the upstream LICENSE file.
  default = "GPL-3.0"
}

variable "SOURCE" {
  default = "https://github.com/beromir/Servas"
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
