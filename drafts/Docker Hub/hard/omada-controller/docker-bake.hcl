target "docker-metadata-action" {}

variable "APP" {
  default = "omada-controller"
}

variable "VERSION" {
  // renovate: datasource=docker depName=mbentley/omada-controller versioning=loose
  default = "6.3.0.111"
}

variable "MONGODB_VERSION" {
  // renovate: datasource=github-tags depName=mongodb/mongo extractVersion=^r(?<version>\d+\.\d+\.\d+)$ versioning=semver
  // UNVERIFIED: restrict to the 8.0 line with allowedVersions, Omada v6 is tested with MongoDB 8.0
  default = "8.0.38"
}

variable "OMADA_URL" {
  // UNVERIFIED: resolved through mbentley's version resolver, the URL embeds a build date and must move with VERSION
  default = "https://static.tp-link.com/upload/software/2026/202610/20261016/Omada_Network_Application_v6.3.0.111_linux_x64_20261009150926.tar.gz"
}

variable "OMADA_SHA256" {
  // UNVERIFIED: empty until the sha256 of OMADA_URL is computed and pinned, the build fails until then
  default = ""
}

variable "LICENSE" {
  // UNVERIFIED: TP-Link proprietary EULA, confirm redistribution rights before publishing
  default = "LicenseRef-TP-Link-Omada-EULA"
}

variable "SOURCE" {
  default = "https://www.tp-link.com/en/omada-sdn/"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    MONGODB_VERSION = "${MONGODB_VERSION}"
    OMADA_URL = "${OMADA_URL}"
    OMADA_SHA256 = "${OMADA_SHA256}"
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
