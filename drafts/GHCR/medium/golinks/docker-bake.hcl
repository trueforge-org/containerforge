target "docker-metadata-action" {}

variable "APP" {
  default = "golinks"
}

variable "VERSION" {
  // renovate: datasource=git-tags depName=https://git.mills.io/prologic/golinks versioning=semver
  default = "v0.0.7"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://git.mills.io/prologic/golinks"
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
