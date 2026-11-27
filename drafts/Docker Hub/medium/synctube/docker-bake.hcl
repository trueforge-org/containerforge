target "docker-metadata-action" {}

variable "APP" {
  default = "synctube"
}

variable "VERSION" {
  // renovate: datasource=git-refs depName=https://github.com/RblSb/SyncTube currentValue=master
  default = "d22d837ae76abe6df3d1dbce3eae0a52297a461b"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/RblSb/SyncTube"
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
