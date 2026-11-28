target "docker-metadata-action" {}

variable "APP" {
  default = "tonido"
}

variable "VERSION" {
  // renovate: none. Closed source, end-of-life, no release feed. Bump manually with the URL and checksum below.
  default = "14.90.0.34042"
}

variable "LICENSE" {
  default = "LicenseRef-Proprietary"
}

variable "SOURCE" {
  default = "https://www.tonido.com/"
}

variable "TONIDO_URL" {
  default = "https://web.archive.org/web/20211006184819id_/https://www.tonido.com/download.php?tonido64.tar.gz"
}

variable "TONIDO_SHA256" {
  default = "d5b582f53d455e083604b306c7cb98e836579b5fa9f3c74efc0ccd72157f3a84"
}

variable "LIBPNG12_URL" {
  default = "http://archive.ubuntu.com/ubuntu/pool/main/libp/libpng/libpng12-0_1.2.54-1ubuntu1.1_amd64.deb"
}

variable "LIBPNG12_SHA256" {
  default = "9d938a376dafd1668827ceeb742f18b164c390e53774b06eaaf644713b6ffb25"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    TONIDO_URL = "${TONIDO_URL}"
    TONIDO_SHA256 = "${TONIDO_SHA256}"
    LIBPNG12_URL = "${LIBPNG12_URL}"
    LIBPNG12_SHA256 = "${LIBPNG12_SHA256}"
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
