target "docker-metadata-action" {}

variable "APP" {
  default = "actions-runner"
}

variable "VERSION" {
  default = "2.330.0"
}

variable "BUILDX_VERSION" {
  default = "0.28.0"
}

variable "RUNNER_CONTAINER_HOOKS_VERSION" {
  default = "0.8.0"
}

variable "DOCKER_VERSION" {
  default = "28.4.0"
}

variable "LICENSE" {
  default = "AGPL-3.0-or-later"
}

variable "SOURCE" {
  default = "https://github.com/actions/runner"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    BUILDX_VERSION = "${BUILDX_VERSION}"
    RUNNER_CONTAINER_HOOKS_VERSION = "${RUNNER_CONTAINER_HOOKS_VERSION}"
    DOCKER_VERSION = "${DOCKER_VERSION}"
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
