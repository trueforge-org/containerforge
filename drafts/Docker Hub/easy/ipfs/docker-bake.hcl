target "docker-metadata-action" {}

variable "APP" {
  default = "ipfs"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=ipfs/kubo
  default = "v0.43.2"
}

variable "LICENSE" {
  default = "Apache-2.0 OR MIT"
}

variable "SOURCE" {
  default = "https://github.com/ipfs/kubo"
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
