target "docker-metadata-action" {}

variable "APP" {
  default = "fileshelter"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=epoupon/fileshelter versioning=semver
  default = "6.4.0"
}

variable "WT_VERSION" {
  // renovate: datasource=github-releases depName=emweb/wt versioning=loose
  default = "4.12.6"
}

// UNVERIFIED: GPL-3.0-only vs GPL-3.0-or-later; confirm against COPYING and source headers.
variable "LICENSE" {
  default = "GPL-3.0-only"
}

variable "SOURCE" {
  default = "https://github.com/epoupon/fileshelter"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION    = "${VERSION}"
    WT_VERSION = "${WT_VERSION}"
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
