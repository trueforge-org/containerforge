target "docker-metadata-action" {}

variable "APP" {
  default = "searxng"
}

variable "VERSION" {
  // renovate: datasource=docker depName=docker.io/searxng/searxng versioning=regex:^(?<major>\d{4})\.(?<minor>\d{2})\.(?<patch>\d{2})-[0-9a-f]+$
  default = "2026.11.28-b98615a25"
}

variable "SOURCE_REF" {
  // Full commit SHA behind the VERSION tag. Update together with VERSION.
  default = "1ebea4a073ec6011bae25c042d97308278184c83"
}

variable "LICENSE" {
  default = "AGPL-3.0-or-later"
}

variable "SOURCE" {
  default = "https://github.com/searxng/searxng"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    SOURCE_REF = "${SOURCE_REF}"
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
