target "docker-metadata-action" {}

variable "APP" {
  default = "nextpvr"
}

variable "VERSION" {
  // renovate: datasource=docker depName=nextpvr/nextpvr_amd64 versioning=loose
  // UNVERIFIED: the Docker Hub tag is only a version signal. The download zip is unversioned and
  // NPVR_SHA256 is bumped by hand. Check with maintainers.
  default = "7.1.1.260616"
}

variable "NPVR_SHA256" {
  // sha256 of http://nextpvr.com/stable/linux/NPVR.zip, fetched 2026-11-26. Bump together with VERSION.
  default = "dc3fabfac0135702037298f4320a046c7c2960921bba33329f33f1f93e2ad97d"
}

variable "LICENSE" {
  // Proprietary: free for personal, non-commercial use. Redistribution needs permission. See the PR notes.
  default = "LicenseRef-NextPVR-Proprietary"
}

variable "SOURCE" {
  default = "https://nextpvr.com"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    NPVR_SHA256 = "${NPVR_SHA256}"
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
  // amd64 only. The zip has arm64 code but it is untested.
  platforms = [
    "linux/amd64"
  ]
}
