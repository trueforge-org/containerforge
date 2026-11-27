target "docker-metadata-action" {}

variable "APP" {
  default = "proxmox-backup-server"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=ayufan/pve-backup-server-dockerfiles versioning=loose extractVersion=^v(?<version>.+)$
  default = "4.2.0-1"
}

variable "PBS_SHA256_AMD64" {
  // UNVERIFIED: fill with the SHA-256 digest of proxmox-backup-server-v${VERSION}-amd64.tgz from the GitHub API.
  default = ""
}

variable "PBS_SHA256_ARM64" {
  // UNVERIFIED: fill with the SHA-256 digest of proxmox-backup-server-v${VERSION}-arm64.tgz from the GitHub API.
  default = ""
}

variable "LICENSE" {
  // UNVERIFIED: confirm from the package copyright files before release.
  default = "AGPL-3.0-or-later"
}

variable "SOURCE" {
  default = "https://github.com/ayufan/pve-backup-server-dockerfiles/"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    PBS_SHA256_AMD64 = "${PBS_SHA256_AMD64}"
    PBS_SHA256_ARM64 = "${PBS_SHA256_ARM64}"
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
