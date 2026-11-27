target "docker-metadata-action" {}

variable "APP" {
  default = "strapi"
}

variable "VERSION" {
  // renovate: datasource=npm depName=@strapi/strapi versioning=semver
  default = "5.64.0"
}

variable "LICENSE" {
  // Community Edition is MIT. Code under ee/ directories uses the Enterprise license.
  // UNVERIFIED: confirm the LICENSE value with the maintainers before publishing.
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/strapi/strapi"
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
