target "docker-metadata-action" {}

variable "APP" {
  default = "uptimerobot-prometheus"
}

variable "VERSION" {
  // renovate: datasource=git-refs depName=https://github.com/lekpamartin/uptimerobot_exporter versioning=loose
  // Commit date of UPTIMEROBOT_COMMIT (20261115), kept in sync by hand.
  default = "20261115"
}

variable "UPTIMEROBOT_COMMIT" {
  // renovate: datasource=git-refs depName=https://github.com/lekpamartin/uptimerobot_exporter versioning=loose
  default = "a64c74a3690080b2bfb65c947b050d8a76bef15b"
}

variable "LICENSE" {
  default = "Apache-2.0"
}

variable "SOURCE" {
  default = "https://github.com/lekpamartin/uptimerobot_exporter"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    UPTIMEROBOT_COMMIT = "${UPTIMEROBOT_COMMIT}"
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
