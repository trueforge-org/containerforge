target "docker-metadata-action" {}

variable "APP" {
  default = "openspeedtest"
}

variable "VERSION" {
  // renovate: datasource=git-refs depName=https://github.com/openspeedtest/Speed-Test versioning=loose
  // No releases or tags exist, so VERSION is a commit SHA on main.
  default = "f4263546f50694a154fdd27a03000390949068df"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/openspeedtest/Speed-Test"
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
