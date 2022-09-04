variable "env" {}

variable "vpc" {
  type    = any
  default = {}
}

variable "configuration" {
  description = "The total configuration, List of Objects/Dictionary"
  default     = [{}]
}

