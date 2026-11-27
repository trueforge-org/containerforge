target "docker-metadata-action" {}

variable "APP" {
  default = "muximux"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=mescon/Muximux versioning=semver
  default = "v3.7.4"
}

// UNVERIFIED: confirm the SPDX suffix (GPL-2.0-only or GPL-2.0-or-later) from the source headers.
variable "LICENSE" {
  default = "GPL-2.0"
}

variable "SOURCE" {
  default = "https://github.com/mescon/Muximux"
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
