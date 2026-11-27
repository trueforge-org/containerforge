target "docker-metadata-action" {}

variable "APP" {
  default = "ntfy"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=binwiederhier/ntfy versioning=semver
  default = "2.38.2"
}

variable "LICENSE" {
  default = "Apache-2.0 OR GPL-2.0-only"
}

variable "SOURCE" {
  default = "https://github.com/binwiederhier/ntfy"
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
