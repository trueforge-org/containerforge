target "docker-metadata-action" {}

variable "APP" {
  default = "automatic-ripping-machine"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=automatic-ripping-machine/automatic-ripping-machine versioning=semver
  default = "2.25.0"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/automatic-ripping-machine/automatic-ripping-machine"
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
