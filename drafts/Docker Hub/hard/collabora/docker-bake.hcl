target "docker-metadata-action" {}

variable "APP" {
  default = "collabora"
}

variable "VERSION" {
  // renovate: datasource=docker depName=docker.io/collabora/code versioning=loose
  default = "26.04.6.2.1"
}

variable "LICENSE" {
  // UNVERIFIED: MPL-2.0 from the COPYING header per plan.md. Bundled LibreOffice components carry their own licences.
  default = "MPL-2.0"
}

variable "SOURCE" {
  default = "https://github.com/CollaboraOnline/online"
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
