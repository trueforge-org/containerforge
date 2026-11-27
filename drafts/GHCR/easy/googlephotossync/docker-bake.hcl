target "docker-metadata-action" {}

variable "APP" {
  default = "googlephotossync"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=gilesknap/gphotos-sync versioning=semver
  // Upstream is archived (2024-10-04). 3.2.5 is the last release.
  default = "3.2.5"
}

variable "LICENSE" {
  default = "Apache-2.0"
}

variable "SOURCE" {
  default = "https://github.com/gilesknap/gphotos-sync"
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
