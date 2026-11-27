target "docker-metadata-action" {}

variable "APP" {
  default = "wekan"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=wekan/wekan versioning=semver
  // Pinned to 13.20 as the draft asks; upstream latest and the chart use 13.35 (separate bump).
  default = "13.20"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/wekan/wekan"
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
