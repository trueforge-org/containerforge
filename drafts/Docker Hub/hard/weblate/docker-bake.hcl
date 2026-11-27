target "docker-metadata-action" {}

variable "APP" {
  default = "weblate"
}

variable "VERSION" {
  // renovate: datasource=pypi depName=Weblate versioning=pep440
  default = "2026.11.2"
}

variable "LICENSE" {
  default = "GPL-3.0-or-later"
}

variable "SOURCE" {
  default = "https://github.com/WeblateOrg/weblate"
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
