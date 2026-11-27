target "docker-metadata-action" {}

variable "APP" {
  default = "dizquetv"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=vexorian/dizquetv versioning=loose
  default = "1.7.0"
}

variable "LICENSE" {
  default = "Zlib"
}

variable "SOURCE" {
  default = "https://github.com/vexorian/dizquetv"
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
