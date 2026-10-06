variable "name" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "security_group_ids" {
  type = list(string)
}

variable "key_name" {
  type        = string
  description = "Name of the EC2 key pair for SSH"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "root_volume_size" {
  type        = number
  description = "GB"
  default     = 8
}

variable "user_data" {
  type        = string
  description = "Script that runs on the first boot"
  default     = null
}
