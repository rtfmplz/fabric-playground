##################################################
# Public Security Group
##################################################
resource "aws_security_group" "public-sg" {
  name        = "public-sg"
  description = "Security Group for application servers"
  vpc_id      = "${aws_vpc.vpc.id}"

  ##################################################
  # inbound
  ##################################################
  ingress {
    description = "ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "test sample nginx"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "for peer"
    from_port   = 57051
    to_port     = 57051
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "from other orgs to orderer"
    from_port   = 57050
    to_port     = 57050
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "health check for gateway"
    from_port   = 57999
    to_port     = 57999
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "for peer in other organization"
    from_port   = 7050
    to_port     = 7050
    protocol    = "tcp"
    cidr_blocks = "${var.private_subnets}"
  }

  ingress {
    description = "for orderer in other organization"
    from_port   = 7051
    to_port     = 7051
    protocol    = "tcp"
    cidr_blocks = "${var.private_subnets}"
  }

  ##################################################
  # outbound
  ##################################################
  egress {
    description = "ssh for public-subnet"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Download docker image through internet gateway"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Download docker-compose through https"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "for orderer in other organization"
    from_port   = 7050
    to_port     = 7050
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "for peer in other organization"
    from_port   = 7051
    to_port     = 7051
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "for peer in other organization"
    from_port   = 5984
    to_port     = 5984
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
