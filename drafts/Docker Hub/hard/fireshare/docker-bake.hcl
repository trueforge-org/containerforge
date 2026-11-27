target "docker-metadata-action" {}

variable "APP" {
  default = "fireshare"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=fireshare-app/fireshare versioning=semver
  // UNVERIFIED: the plan read 1.9.4, later reports show newer tags (1.9.5, and 1.9.6 in a chart). Re-check before building.
  default = "1.9.4"
}

variable "LICENSE" {
  default = "GPL-3.0-only"
}

variable "SOURCE" {
  default = "https://github.com/fireshare-app/fireshare"
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
