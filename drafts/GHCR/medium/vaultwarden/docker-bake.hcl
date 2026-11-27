target "docker-metadata-action" {}

variable "APP" {
  default = "vaultwarden"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=dani-garcia/vaultwarden versioning=semver
  default = "1.37.5"
}

// UNVERIFIED: GitHub reports AGPL-3.0. Confirm -only or -or-later from LICENSE.txt.
variable "LICENSE" {
  default = "AGPL-3.0"
}

variable "SOURCE" {
  default = "https://github.com/dani-garcia/vaultwarden"
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
