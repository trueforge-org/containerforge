target "docker-metadata-action" {}

variable "APP" {
  default = "nextcloud-fpm"
}

variable "VERSION" {
  // renovate: datasource=docker depName=public.ecr.aws/docker/library/nextcloud versioning=regex:^(?<major>\d+)\.(?<minor>\d+)\.(?<patch>\d+)-fpm$
  default = "32.0.5-fpm"
}

variable "LICENSE" {
  default = "AGPL-3.0-or-later"
}


variable "SOURCE" {
  default = "https://nextcloud.com"
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
