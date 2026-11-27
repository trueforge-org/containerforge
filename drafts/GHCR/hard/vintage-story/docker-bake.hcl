target "docker-metadata-action" {}

variable "APP" {
  default = "vintage-story"
}

variable "VERSION" {
  // renovate: datasource=custom.vintagestory depName=vintagestory versioning=semver
  // UNVERIFIED: needs a custom renovate manager for api.vintagestory.at before this annotation works
  default = "1.22.7"
}

variable "LICENSE" {
  // UNVERIFIED: closed-source server, no SPDX license found; confirm before merge
  default = "LicenseRef-Proprietary"
}

variable "SOURCE" {
  default = "https://www.vintagestory.at/"
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
  // amd64 only: the vendor publishes no Linux arm64 server build
  platforms = [
    "linux/amd64"
  ]
}
