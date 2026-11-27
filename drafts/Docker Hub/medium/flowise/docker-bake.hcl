target "docker-metadata-action" {}

variable "APP" {
  default = "flowise"
}

variable "VERSION" {
  // renovate: datasource=npm depName=flowise versioning=npm
  default = "3.1.4"
}

variable "LICENSE" {
  // NEEDS HUMAN DECISION: Apache-2.0 with a Commercial License for enterprise/ (plan section 10). Not a single SPDX id.
  default = "Apache-2.0"
}

variable "SOURCE" {
  default = "https://github.com/FlowiseAI/Flowise"
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
