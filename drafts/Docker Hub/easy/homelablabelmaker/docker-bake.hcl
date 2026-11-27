target "docker-metadata-action" {}

variable "APP" {
  default = "homelablabelmaker"
}

variable "VERSION" {
  // renovate: datasource=git-refs depName=https://github.com/DavidSpek/homelablabelmaker currentValue=master
  default = "d52776c7bd405bf388f53a725a640f2c1a461ae4"
}

variable "LICENSE" {
  // UNVERIFIED placeholder: upstream has no LICENSE file. Confirm with the maintainer before merging.
  default = "NOASSERTION"
}

variable "SOURCE" {
  default = "https://github.com/DavidSpek/homelablabelmaker"
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
