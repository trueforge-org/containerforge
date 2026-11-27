target "docker-metadata-action" {}

variable "APP" {
  default = "backrest"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=garethgeorge/backrest versioning=semver
  default = "1.14.1"
}

variable "RESTIC_VERSION" {
  // renovate: datasource=github-releases depName=restic/restic versioning=semver
  // UNVERIFIED: restic v0.20.0 is the latest upstream release; backrest's bundled restic version is not confirmed.
  default = "0.20.0"
}

variable "LICENSE" {
  // GitHub reports SPDX GPL-3.0 for the repo
  default = "GPL-3.0"
}

variable "SOURCE" {
  default = "https://github.com/garethgeorge/backrest"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    RESTIC_VERSION = "${RESTIC_VERSION}"
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
