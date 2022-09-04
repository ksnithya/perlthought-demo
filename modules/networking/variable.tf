variable "env" {}
variable "vpc_cidr" {
  type = string
}
variable "private_subnets" {
  type = any
}
variable "public_subnets" {
  type = any
}

