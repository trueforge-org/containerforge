target "docker-metadata-action" {}

variable "APP" {
  default = "phpldapadmin"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=leenooks/phpLDAPadmin versioning=semver
  default = "2.3.13"
}

variable "LICENSE" {
  // UNVERIFIED: repo LICENSE reads GPL-2.0, composer.json says MIT; confirm before merging
  default = "GPL-2.0-only"
}

variable "SOURCE" {
  default = "https://github.com/leenooks/phpLDAPadmin/"
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
