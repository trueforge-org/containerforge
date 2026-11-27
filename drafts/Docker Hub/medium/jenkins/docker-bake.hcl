target "docker-metadata-action" {}

variable "APP" {
  default = "jenkins"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=jenkinsci/jenkins versioning=loose
  default = "2.544"
}

// Not managed by renovate: update together with VERSION, from get.jenkins.io/war/<version>/jenkins.war.sha256
variable "WAR_SHA256" {
  default = "58d2c25c42859d0423329221629c9d4f99e68d68cb50d7c61f4474c27938a973"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/jenkinsci/jenkins"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    WAR_SHA256 = "${WAR_SHA256}"
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
