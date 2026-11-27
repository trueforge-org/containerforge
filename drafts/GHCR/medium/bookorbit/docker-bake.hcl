target "docker-metadata-action" {}

variable "APP" {
  default = "bookorbit"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=bookorbit/bookorbit versioning=semver
  default = "v3.10.0"
}

variable "LICENSE" {
  default = "AGPL-3.0-only"
}

variable "SOURCE" {
  default = "https://github.com/bookorbit/bookorbit"
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
