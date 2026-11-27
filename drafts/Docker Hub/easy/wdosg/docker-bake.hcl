target "docker-metadata-action" {}

variable "APP" {
  default = "wdosg"
}

variable "VERSION" {
  // renovate: datasource=github-tags depName=SoulRaven80/wdosg versioning=semver
  default = "1.3.9"
}

variable "LICENSE" {
  // UNVERIFIED conflict: LICENSE file is GPLv3, package.json says ISC. The LICENSE file is taken as authoritative.
  default = "GPL-3.0-only"
}

variable "SOURCE" {
  default = "https://github.com/SoulRaven80/wdosg"
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
