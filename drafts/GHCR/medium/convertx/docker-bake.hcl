target "docker-metadata-action" {}

variable "APP" {
  default = "convertx"
}

variable "VERSION" {
  // renovate: datasource=github-tags depName=C4illin/ConvertX versioning=semver
  default = "0.20.0"
}

variable "BUN_VERSION" {
  // renovate: datasource=docker depName=docker.io/oven/bun versioning=semver
  // UNVERIFIED: no digest recorded for oven/bun:1.4.4-slim
  default = "1.4.4"
}

variable "VTRACER_VERSION" {
  // renovate: datasource=github-releases depName=visioncortex/vtracer versioning=semver
  default = "0.6.4"
}

variable "LICENSE" {
  // UNVERIFIED: AGPL-3.0 from GitHub SPDX; confirm -only or -or-later from the LICENSE file
  default = "AGPL-3.0"
}

variable "SOURCE" {
  default = "https://github.com/C4illin/ConvertX"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    BUN_VERSION = "${BUN_VERSION}"
    VTRACER_VERSION = "${VTRACER_VERSION}"
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
