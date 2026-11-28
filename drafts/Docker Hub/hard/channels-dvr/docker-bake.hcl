target "docker-metadata-action" {}

variable "APP" {
  default = "channels-dvr"
}

variable "VERSION" {
  // renovate: datasource=custom.channels-dvr depName=channels-dvr
  // No standard Renovate datasource exists. Value is https://cdn.channelsdvr.net/dvr/latest.txt as read on 2026-11-28; needs a custom datasource or a manual bump.
  default = "2026.10.24.0621"
}

variable "LICENSE" {
  default = "LicenseRef-Proprietary"
}

variable "SOURCE" {
  default = "https://getchannels.com/dvr-server/"
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
