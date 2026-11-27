target "docker-metadata-action" {}

variable "APP" {
  default = "shorturl"
}

variable "VERSION" {
  // renovate: datasource=git-tags depName=https://git.mills.io/prologic/shorturl versioning=semver
  // UNVERIFIED: Renovate may not read this Gitea host; if not, bump manually.
  default = "v0.1.0"
}

variable "CHECKSUM" {
  // UNVERIFIED: sha256 of the v0.1.0 source tarball. Not published on a fetched page; compute it from the downloaded archive and set it here.
  default = ""
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://git.mills.io/prologic/shorturl"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    CHECKSUM = "${CHECKSUM}"
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
