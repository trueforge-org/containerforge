target "docker-metadata-action" {}

variable "APP" {
  default = "static"
}

variable "VERSION" {
  // renovate: UNVERIFIED datasource and depName (git.mills.io); resolve before merge
  default = "0.0.2"
}

variable "LICENSE" {
  // UNVERIFIED: MIT (git.mills.io sidebar) vs "MIC License" (README); resolve before merge
  default = "UNVERIFIED"
}

variable "SOURCE" {
  default = "https://git.mills.io/prologic/static"
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
