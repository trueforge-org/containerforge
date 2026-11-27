target "docker-metadata-action" {}

variable "APP" {
  default = "openobserve"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=openobserve/openobserve versioning=semver
  default = "v1.2.0"
}

variable "LICENSE" {
  default = "AGPL-3.0"
}

variable "SOURCE" {
  default = "https://github.com/openobserve/openobserve"
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
