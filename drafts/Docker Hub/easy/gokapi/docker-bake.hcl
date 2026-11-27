target "docker-metadata-action" {}

variable "APP" {
  default = "gokapi"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=Forceu/Gokapi
  default = "2.2.4"
}

// UNVERIFIED: "AGPL-3.0-only" vs "AGPL-3.0-or-later" (no project-specific statement found).
variable "LICENSE" {
  default = "AGPL-3.0-only"
}

variable "SOURCE" {
  default = "https://github.com/Forceu/Gokapi"
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
