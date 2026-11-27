target "docker-metadata-action" {}

variable "APP" {
  default = "cowyo"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=schollz/cowyo versioning=semver
  default = "3.0.1"
}

variable "LICENSE" {
  // UNVERIFIED: README states MIT, but no LICENSE file was found on main. Confirm against the v3.0.1 tree before the first build.
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/schollz/cowyo"
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
