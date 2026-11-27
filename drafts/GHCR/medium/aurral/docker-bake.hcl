target "docker-metadata-action" {}

variable "APP" {
  default = "aurral"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=lklynet/aurral versioning=semver
  default = "3.1.0"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/lklynet/aurral"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    APP_VERSION = "${VERSION}"
    GITHUB_REPO = "lklynet/aurral"
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
