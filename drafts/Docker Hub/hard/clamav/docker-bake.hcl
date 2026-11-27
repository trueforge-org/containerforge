target "docker-metadata-action" {}

variable "APP" {
  default = "clamav"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=Cisco-Talos/clamav extractVersion=^clamav-(?<version>.+)$ versioning=semver
  default = "1.5.5"
}

variable "LICENSE" {
  // UNVERIFIED: COPYING.txt is GPL-2.0 with an OpenSSL exception, the "only" vs "or later" choice is not settled
  default = "GPL-2.0-only"
}

variable "SOURCE" {
  default = "https://github.com/Cisco-Talos/clamav/"
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
