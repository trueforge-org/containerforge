target "docker-metadata-action" {}

variable "APP" {
  default = "dell-idrac-fan-controller"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=tigerblue77/Dell_iDRAC_fan_controller_Docker versioning=loose
  default = "1.108"
}

variable "LICENSE" {
  // UNVERIFIED: the upstream image label says AGPL-3.0-only; the packaged LICENSE has no SPDX line. Confirm at the tag.
  default = "AGPL-3.0-only"
}

variable "SOURCE" {
  default = "https://github.com/tigerblue77/Dell_iDRAC_fan_controller_Docker"
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
