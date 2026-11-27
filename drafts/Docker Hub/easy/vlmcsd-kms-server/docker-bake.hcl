target "docker-metadata-action" {}

variable "APP" {
  default = "vlmcsd-kms-server"
}

variable "VERSION" {
  // renovate: datasource=github-tags depName=Wind4/vlmcsd versioning=loose
  default = "svn1113"
}

// UNVERIFIED: upstream has no LICENSE file at this tag; set once maintainers decide.
variable "LICENSE" {
  default = "NOASSERTION"
}

variable "SOURCE" {
  default = "https://github.com/Wind4/vlmcsd"
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
