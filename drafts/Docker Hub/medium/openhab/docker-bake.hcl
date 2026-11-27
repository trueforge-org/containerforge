target "docker-metadata-action" {}

variable "APP" {
  default = "openhab"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=openhab/openhab-distro versioning=semver
  default = "5.2.5"
}

variable "LICENSE" {
  default = "EPL-2.0"
}

variable "SOURCE" {
  default = "https://github.com/openhab/openhab-distro"
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
