target "docker-metadata-action" {}

variable "APP" {
  default = "valetudo-mapper"
}

variable "VERSION" {
  // renovate: datasource=git-refs depName=https://github.com/rand256/valetudo-mapper versioning=loose
  // Version from package.json at VALETUDO_MAPPER_COMMIT, kept in sync by hand.
  default = "0.5.0"
}

variable "VALETUDO_MAPPER_COMMIT" {
  // renovate: datasource=git-refs depName=https://github.com/rand256/valetudo-mapper versioning=loose
  default = "54aba3534e9e797b9a22c0e134fa2706effd2e9d"
}

variable "LICENSE" {
  default = "Apache-2.0"
}

variable "SOURCE" {
  default = "https://github.com/rand256/valetudo-mapper"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    VALETUDO_MAPPER_COMMIT = "${VALETUDO_MAPPER_COMMIT}"
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
