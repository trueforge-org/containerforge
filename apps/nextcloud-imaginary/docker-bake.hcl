target "docker-metadata-action" {}

variable "APP" {
  default = "Nextcloud-imaginary"
}

variable "VERSION" {
  default = "20230401"
}

variable "IMAGINARY_COMMMIT" {
  // renovate: datasource=git-refs depName=https://github.com/h2non/imaginary
  default = "b632dae8cc321452c3f85bcae79c580b1ae1ed84"
}


variable "LICENSE" {
  default = "AGPL-3.0-or-later"
}

variable "SOURCE" {
  default = "https://nextcloud.com"
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
