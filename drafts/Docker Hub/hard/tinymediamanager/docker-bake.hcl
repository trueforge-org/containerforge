target "docker-metadata-action" {}

variable "APP" {
  default = "tinymediamanager"
}

variable "VERSION" {
  // renovate: datasource=gitlab-tags depName=tinyMediaManager/tinyMediaManager versioning=semver extractVersion=^tinyMediaManager-(?<version>.+)$
  default = "5.3.5"
}

variable "LICENSE" {
  default = "Apache-2.0"
}

variable "SOURCE" {
  default = "https://gitlab.com/tinyMediaManager/tinyMediaManager"
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
