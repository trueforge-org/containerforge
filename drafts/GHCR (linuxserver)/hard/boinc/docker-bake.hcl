target "docker-metadata-action" {}

variable "APP" {
  default = "boinc"
}

variable "VERSION" {
  // renovate: UNVERIFIED datasource for an Ubuntu archive pin; placeholder until confirmed
  // UNVERIFIED: client version from the 26.04 archive; not yet known
  default = "UNVERIFIED"
}

variable "BOINC_VERSION" {
  default = "UNVERIFIED" // UNVERIFIED: apt version string for boinc-client on 26.04, must match VERSION
}

variable "LICENSE" {
  default = "LGPL-3.0-or-later"
}

variable "SOURCE" {
  default = "https://github.com/BOINC/boinc"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    BOINC_VERSION = "${BOINC_VERSION}"
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

// UNVERIFIED: arm64 availability for boinc-client on 26.04 is not confirmed
target "image-all" {
  inherits = ["image"]
  platforms = [
    "linux/amd64",
    "linux/arm64"
  ]
}
