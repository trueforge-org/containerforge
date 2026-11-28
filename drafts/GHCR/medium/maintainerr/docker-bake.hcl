target "docker-metadata-action" {}

variable "APP" {
  default = "maintainerr"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=Maintainerr/Maintainerr versioning=semver
  // plan builds 3.33.0; the chart pins 3.33.0 too (plan section 10 predates the chart bump)
  default = "3.33.0"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/Maintainerr/Maintainerr"
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
