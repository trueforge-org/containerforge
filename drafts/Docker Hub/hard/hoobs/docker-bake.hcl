target "docker-metadata-action" {}

variable "APP" {
  default = "hoobs"
}

variable "VERSION" {
  // renovate: datasource=npm depName=@hoobs/hoobs versioning=semver
  default = "3.3.12"
}

// UNVERIFIED: GPL-3.0 from npm metadata; -only vs -or-later to confirm. The README states no license.
variable "LICENSE" {
  default = "GPL-3.0-only"
}

variable "SOURCE" {
  default = "https://github.com/hoobs-org/HOOBS"
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
