target "docker-metadata-action" {}

variable "APP" {
  default = "tsmuxer"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=justdan96/tsMuxer versioning=loose
  default = "2.7.0"
}

variable "LICENSE" {
  default = "Apache-2.0"
}

variable "SOURCE" {
  default = "https://github.com/justdan96/tsMuxer"
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
  // amd64 only: upstream publishes no arm64 release asset
  platforms = [
    "linux/amd64"
  ]
}
