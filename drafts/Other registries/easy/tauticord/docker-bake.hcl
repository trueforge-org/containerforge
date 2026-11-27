target "docker-metadata-action" {}

variable "APP" {
  default = "tauticord"
}

variable "VERSION" {
  // renovate: datasource=gitea depName=codeberg.org/nwithan8/tauticord versioning=semver
  // UNVERIFIED: the Codeberg (gitea) renovate datasource is not confirmed against the Renovate docs.
  default = "6.2.0"
}

variable "LICENSE" {
  // UNVERIFIED: LICENSE file is GNU GPL v3 text; confirm -only vs -or-later against the repo licence field.
  default = "GPL-3.0"
}

variable "SOURCE" {
  default = "https://codeberg.org/nwithan8/tauticord"
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
