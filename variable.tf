variable "env" {
  type    = string
  default = "dev"
}

variable "region" {
  description = "AWS region"
  default     = "ap-south-1"
  type        = string
}
 
variable "configuration" {
  description = "The total configuration, List of Objects/Dictionary"
  default     = [{}]
}

variable "ssh_allowed_ips" {
  type    = string
  default = "0.0.0.0/0"
}

variable "vpc_cidr" {
  type    = string
  default = "10.2.0.0/16"
}

variable "private_subnets" {
  type    = any
  default = ["10.2.0.0/20", "10.2.16.0/20", "10.2.32.0/20"]
}

variable "public_subnets" {
  type    = any
  default = ["10.2.240.0/24", "10.2.241.0/24", "10.2.242.0/24"]
}

