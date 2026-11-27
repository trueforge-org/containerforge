target "docker-metadata-action" {}

variable "APP" {
  default = "drawio"
}

// UNVERIFIED: a newer release (32.7.7) exists and TrueCharts uses it. Kept at 32.7.4 per the plan's maintainer decision.
variable "VERSION" {
  // renovate: datasource=github-releases depName=jgraph/drawio versioning=semver extractVersion=^v(?<version>.+)$
  default = "32.7.4"
}

// UNVERIFIED: renovate datasource for Tomcat 9 (maven artifact org.apache.tomcat:tomcat assumed).
variable "TOMCAT_VERSION" {
  // renovate: datasource=maven depName=org.apache.tomcat:tomcat versioning=semver
  default = "9.0.124"
}

variable "LICENSE" {
  default = "Apache-2.0"
}

variable "SOURCE" {
  default = "https://github.com/jgraph/drawio"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    TOMCAT_VERSION = "${TOMCAT_VERSION}"
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
