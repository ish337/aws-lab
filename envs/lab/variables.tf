variable "region" {
  type    = string
  default = "eu-central-1"
}

variable "environment" {
  type        = string
  description = "Environment name, goes to the resource names and the Environment tag"
  default     = "lab"
}

// Network
variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  type    = string
  default = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  type    = string
  default = "10.0.2.0/24"
}

variable "my_ip" {
  type        = string
  description = "Workstation IP as a CIDR, e.g. 203.0.113.10/32, SSH and HTTP are open only for it"

  validation {
    condition     = can(cidrhost(var.my_ip, 0))
    error_message = "my_ip must be a CIDR, e.g. 203.0.113.10/32."
  }
}

// Compute
variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "ssh_public_key" {
  type        = string
  description = "Public key for the ubuntu user on both instances"
}
