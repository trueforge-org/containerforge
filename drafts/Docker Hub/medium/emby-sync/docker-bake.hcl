target "docker-metadata-action" {}

variable "APP" {
  default = "emby-sync"
}

variable "VERSION" {
  // renovate: datasource=git-refs depName=cameronurnes/emby-sync packageName=https://github.com/cameronurnes/emby-sync currentDigest=63bd8b3e952aac416fa18dd1a1d16cb611f63a8e
  default = "63bd8b3e952aac416fa18dd1a1d16cb611f63a8e"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/cameronurnes/emby-sync"
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
