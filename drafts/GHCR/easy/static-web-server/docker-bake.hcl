target "docker-metadata-action" {}

variable "APP" {
  default = "static-web-server"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=static-web-server/static-web-server versioning=semver
  default = "2.44.3"
}

variable "LICENSE" {
  default = "MIT OR Apache-2.0"
}

variable "SOURCE" {
  default = "https://github.com/static-web-server/static-web-server"
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
