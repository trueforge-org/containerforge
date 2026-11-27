target "docker-metadata-action" {}

variable "APP" {
  default = "openttd"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=OpenTTD/OpenTTD versioning=loose
  default = "15.3"
}

// UNVERIFIED: GitHub reports NOASSERTION; believed GPL-2.0-or-later, confirm against upstream COPYING.
variable "LICENSE" {
  default = "GPL-2.0-or-later"
}

variable "SOURCE" {
  default = "https://github.com/OpenTTD/OpenTTD"
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
