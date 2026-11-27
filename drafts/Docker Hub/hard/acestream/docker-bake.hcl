target "docker-metadata-action" {}

variable "APP" {
  default = "acestream"
}

variable "VERSION" {
  // renovate: datasource=docker depName=vstavrinov/acestream-service versioning=loose
  default = "2.1.1.1"
}

variable "ENGINE_VERSION" {
  // Ace Stream engine tarball version, bumped by hand (not renovated). The Dockerfile sha256 must match it.
  default = "3.2.11"
}

variable "ACESTREAM_SEARCH_REF" {
  // UNVERIFIED: commit of vstavrinov/acestream_search to pin, not the moving HEAD
  default = ""
}

variable "LICENSE" {
  // UNVERIFIED: the engine is proprietary and its terms are not cleared. Replace after legal review.
  default = "UNVERIFIED"
}

variable "SOURCE" {
  default = "https://github.com/vstavrinov/acestream-service/"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    ENGINE_VERSION = "${ENGINE_VERSION}"
    ACESTREAM_SEARCH_REF = "${ACESTREAM_SEARCH_REF}"
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
  // Deliberate deviation: the Ace Stream engine has no arm64 build, so this target is amd64 only
  platforms = [
    "linux/amd64"
  ]
}
