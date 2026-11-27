target "docker-metadata-action" {}

variable "APP" {
  default = "mkvcleaver"
}

variable "VERSION" {
  // UNVERIFIED: no renovate datasource tracks MKVCleaver releases (binary is on blogs.sapib.ca). See plan section 5 and 10.
  default = "0802"
}

variable "MKVTOOLNIX_VERSION" {
  default = "33.1.0"
}

variable "MEDIAINFO_VERSION" {
  default = "26.01"
}

variable "LICENSE" {
  // UNVERIFIED: the MKVCleaver licence is not on a fetched page. The jlesage wrapper is MIT, but that is not the app licence.
  default = "UNVERIFIED"
}

variable "SOURCE" {
  default = "https://blogs.sapib.ca/"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    MKVTOOLNIX_VERSION = "${MKVTOOLNIX_VERSION}"
    MEDIAINFO_VERSION = "${MEDIAINFO_VERSION}"
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
