target "docker-metadata-action" {}

variable "APP" {
  default = "nextcloud-imaginary"
}

variable "VERSION" {
  // renovate: datasource=git-refs depName=https://github.com/h2non/imaginary versioning=loose
  default = "20230401"
}

variable "IMAGINARY_COMMIT" {
  // renovate: datasource=git-refs depName=https://github.com/h2non/imaginary versioning=loose
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
    IMAGINARY_COMMIT = "${IMAGINARY_COMMIT}"
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
    "linux/amd64"
  ]
}
