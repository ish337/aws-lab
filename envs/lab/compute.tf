resource "aws_key_pair" "lab" {
  key_name   = "${var.environment}-key"
  public_key = var.ssh_public_key
}

// Web instance in the public subnet: SSH only from my IP,
// out only HTTP/HTTPS (apt) and to the VPC (SSH to the app instance)
resource "aws_security_group" "web" {
  name        = "${var.environment}-web"
  description = "Web instance in the public subnet"
  vpc_id      = module.network.vpc_id

  tags = { Name = "${var.environment}-web" }
}

resource "aws_vpc_security_group_ingress_rule" "web_ssh" {
  security_group_id = aws_security_group.web.id
  description       = "SSH from my IP"
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_ipv4         = var.my_ip
}

// Pre-defined rule for the web page: HTTP to the web instance only from my IP
resource "aws_vpc_security_group_ingress_rule" "web_http_from_me" {
  security_group_id = aws_security_group.web.id
  description       = "HTTP from my IP"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_ipv4         = var.my_ip
}

resource "aws_vpc_security_group_egress_rule" "web_http" {
  security_group_id = aws_security_group.web.id
  description       = "HTTP to the internet"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "web_https" {
  security_group_id = aws_security_group.web.id
  description       = "HTTPS to the internet"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "web_vpc" {
  security_group_id = aws_security_group.web.id
  description       = "Everything inside the VPC"
  ip_protocol       = "-1"
  cidr_ipv4         = var.vpc_cidr
}

// App instance in the private subnet: SSH only from the web instance,
// ping from the VPC, out only HTTP/HTTPS through the NAT gateway
resource "aws_security_group" "app" {
  name        = "${var.environment}-app"
  description = "App instance in the private subnet"
  vpc_id      = module.network.vpc_id

  tags = { Name = "${var.environment}-app" }
}

resource "aws_vpc_security_group_ingress_rule" "app_ssh" {
  security_group_id            = aws_security_group.app.id
  description                  = "SSH from the web instance"
  ip_protocol                  = "tcp"
  from_port                    = 22
  to_port                      = 22
  referenced_security_group_id = aws_security_group.web.id
}

resource "aws_vpc_security_group_ingress_rule" "app_ping" {
  security_group_id = aws_security_group.app.id
  description       = "Ping from the VPC"
  ip_protocol       = "icmp"
  from_port         = -1
  to_port           = -1
  cidr_ipv4         = var.vpc_cidr
}

resource "aws_vpc_security_group_egress_rule" "app_http" {
  security_group_id = aws_security_group.app.id
  description       = "HTTP through the NAT gateway"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "app_https" {
  security_group_id = aws_security_group.app.id
  description       = "HTTPS through the NAT gateway"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_ipv4         = "0.0.0.0/0"
}

module "web" {
  source = "../../modules/instance"

  name               = "${var.environment}-web"
  subnet_id          = module.network.public_subnet_id
  security_group_ids = [aws_security_group.web.id]
  key_name           = aws_key_pair.lab.key_name
  instance_type      = var.instance_type

  // nginx for the HTTP test
  user_data = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y nginx
  EOF
}

module "app" {
  source = "../../modules/instance"

  name               = "${var.environment}-app"
  subnet_id          = module.network.private_subnet_id
  security_group_ids = [aws_security_group.app.id]
  key_name           = aws_key_pair.lab.key_name
  instance_type      = var.instance_type
}
