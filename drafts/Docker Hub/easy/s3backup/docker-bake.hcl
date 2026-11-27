target "docker-metadata-action" {}

variable "APP" {
  default = "s3backup"
}

variable "VERSION" {
  // renovate: datasource=pypi depName=s3cmd versioning=pep440
  default = "2.4.0"
}

variable "LICENSE" {
  default = "GPL-2.0-or-later"
}

variable "SOURCE" {
  default = "https://github.com/s3tools/s3cmd"
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
