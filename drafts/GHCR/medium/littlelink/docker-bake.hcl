target "docker-metadata-action" {}

variable "APP" {
  default = "littlelink"
}

// UNVERIFIED: no releases upstream. Pinned by commit SHA of techno-tim/littlelink-server.
// renovate: datasource=git-refs depName=https://github.com/techno-tim/littlelink-server currentValue=main
variable "VERSION" {
  default = "e7fa7dbb3178fcd963e6472f25e96a874f496a11"
}

// UNVERIFIED: MIT is confirmed for timothystewart6/littlelink-server only, not for the techno-tim fork.
variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/techno-tim/littlelink-server"
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
