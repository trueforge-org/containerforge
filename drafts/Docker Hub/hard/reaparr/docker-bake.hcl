target "docker-metadata-action" {}

variable "APP" {
  default = "reaparr"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=Reaparr/Reaparr versioning=semver
  default = "0.40.0"
}

// UNVERIFIED: no checksum is published for the source tarball. Set this to the sha256 of https://github.com/Reaparr/Reaparr/archive/refs/tags/v${VERSION}.tar.gz before the first build.
variable "REAPARR_SHA256" {
  default = ""
}

// UNVERIFIED: GPL-3.0 is shown on the repository page; use GPL-3.0-or-later if the LICENSE header says so.
variable "LICENSE" {
  default = "GPL-3.0-only"
}

variable "SOURCE" {
  default = "https://github.com/Reaparr/Reaparr/"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    REAPARR_SHA256 = "${REAPARR_SHA256}"
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
