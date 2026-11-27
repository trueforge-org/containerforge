target "docker-metadata-action" {}

variable "APP" {
  default = "obsidian"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=obsidianmd/obsidian-releases versioning=semver
  default = "1.15.1"
}

variable "LICENSE" {
  // UNVERIFIED: no license is named in the fetched sources. Replace with the SPDX id once confirmed.
  default = "NOASSERTION"
}

variable "SOURCE" {
  default = "https://github.com/obsidianmd/obsidian-releases"
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
    "linux/amd64"  // arm64 AppImage not confirmed
  ]
}
