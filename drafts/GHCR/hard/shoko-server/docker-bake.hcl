target "docker-metadata-action" {}

variable "APP" {
  default = "shoko-server"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=ShokoAnime/ShokoServer versioning=semver
  default = "5.3.3"
}

variable "SHOKO_SHA256" {
  // UNVERIFIED: no checksum is published with the release; pin on first download.
  default = ""
}

variable "WEBUI_URL" {
  // BLOCKER: Shoko-WebUI release asset not yet identified.
  default = ""
}

variable "WEBUI_SHA256" {
  // UNVERIFIED: pin on first download.
  default = ""
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/ShokoAnime/ShokoServer"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    SHOKO_SHA256 = "${SHOKO_SHA256}"
    WEBUI_URL = "${WEBUI_URL}"
    WEBUI_SHA256 = "${WEBUI_SHA256}"
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
  // amd64 only until an arm64 build is validated (plan section 4 and 5).
  platforms = [
    "linux/amd64"
  ]
}
