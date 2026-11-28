target "docker-metadata-action" {}

variable "APP" {
  default = "double-take"
}

variable "VERSION" {
  // renovate: datasource=github-tags depName=skrashevich/double-take versioning=loose
  default = "1.13.12.0rc3"
}

variable "LICENSE" {
  // UNVERIFIED for the fork: the upstream jakowenko/double-take is MIT. Confirm the fork's LICENSE.
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/skrashevich/double-take"
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
