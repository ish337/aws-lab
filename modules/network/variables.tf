variable "name" {
  type        = string
  description = "Prefix for the resource names, e.g. lab"
}

variable "vpc_cidr" {
  type = string
}

variable "public_subnet_cidr" {
  type = string
}

variable "private_subnet_cidr" {
  type = string
}

variable "my_ip" {
  type        = string
  description = "Workstation IP as a CIDR, e.g. 203.0.113.10/32, only it can reach the public subnet"
}
