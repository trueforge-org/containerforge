target "docker-metadata-action" {}

variable "APP" {
  default = "convos"
}

variable "VERSION" {
  // renovate: datasource=github-tags depName=convos-chat/convos versioning=semver
  default = "8.07"
}

variable "LICENSE" {
  default = "Artistic-2.0"
}

variable "SOURCE" {
  default = "https://github.com/convos-chat/convos"
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
