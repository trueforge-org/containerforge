target "docker-metadata-action" {}

variable "APP" {
  default = "peanut"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=Brandawg93/PeaNUT versioning=semver
  // UNVERIFIED: the v prefix handling of renovate. Latest upstream release is v6.2.0 (not yet pinned here).
  default = "v6.1.2"
}

variable "LICENSE" {
  default = "Apache-2.0"
}

variable "SOURCE" {
  default = "https://github.com/Brandawg93/PeaNUT"
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
