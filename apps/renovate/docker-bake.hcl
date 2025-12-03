target "docker-metadata-action" {}

variable "APP" {
  default = "renovate"
}

variable "VERSION" {
  // renovate: datasource=docker depName=renovate/renovate
  default = "42.32.3"
}

variable "CLUSTERTOOL_VERSION" {
  // renovate: datasource=github-releases depName=trueforge-org/truecharts
  default = "2.0.6"
}

variable "LICENSE" {
  default = "AGPL-3.0-or-later"
}

variable "SOURCE" {
  default = "https://github.com/renovate/renovate"
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
