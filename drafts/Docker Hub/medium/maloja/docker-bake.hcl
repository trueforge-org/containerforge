target "docker-metadata-action" {}

variable "APP" {
  default = "maloja"
}

variable "VERSION" {
  // renovate: datasource=github-tags depName=krateng/maloja versioning=semver
  default = "3.2.10"
}

variable "LICENSE" {
  // UNVERIFIED: GitHub reports GPL-3.0; confirm -only vs -or-later from the LICENSE header
  default = "GPL-3.0"
}

variable "SOURCE" {
  default = "https://github.com/krateng/maloja"
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
