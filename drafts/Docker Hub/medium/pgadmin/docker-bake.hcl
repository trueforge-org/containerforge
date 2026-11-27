target "docker-metadata-action" {}

variable "APP" {
  default = "pgadmin"
}

variable "VERSION" {
  // renovate: datasource=pypi depName=pgadmin4 versioning=pep440
  default = "9.19"
}

variable "LICENSE" {
  // UNVERIFIED: confirm the SPDX identifier against the repo LICENSE
  default = "PostgreSQL"
}

variable "SOURCE" {
  default = "https://github.com/pgadmin-org/pgadmin4"
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
