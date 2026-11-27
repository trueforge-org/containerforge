target "docker-metadata-action" {}

variable "APP" {
  default = "media-roller"
}

variable "VERSION" {
  // renovate: datasource=git-refs depName=https://github.com/rroller/media-roller currentValue=master
  default = "968415c8a43992941c4aaf54eb7d2f97b85120be"
}

variable "LICENSE" {
  // UNVERIFIED: no license is detected upstream. Set the SPDX value before merge.
  default = "UNVERIFIED"
}

variable "SOURCE" {
  default = "https://github.com/rroller/media-roller"
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
