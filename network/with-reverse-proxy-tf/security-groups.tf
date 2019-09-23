##################################################
# ELB Security Group
##################################################

resource "aws_security_group" "public-lb-sg" {
  name = "public-lb-sg"
  description = "Security Group for public lb"
  vpc_id = "${aws_vpc.vpc.id}"

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  ingress {
    from_port   = 57999          // heath check
    to_port     = 57999
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "tcp"

    cidr_blocks = [
      "${var.public_subnets[0]}",
      "${var.public_subnets[1]}",
    ]
  }

  egress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  tags = {
    Name = "public-lb-sg"
  }
}

##################################################
# Security Group
# [FIXME] ingress 22, 80, 443 / egress 80, 443 이 없으면 ecs cluster의 컨테이너 인스턴스에 ec2가 붙질 않는다..
##################################################
resource "aws_security_group" "webserver-sg" {
  name        = "webserver-sg"
  description = "Security Group for public web servers"
  vpc_id      = "${aws_vpc.vpc.id}"

  ingress {
    from_port   = 22            // nginx-test
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80            // nginx-test
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443           // https
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 57999          // heath check
    to_port     = 57999
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 80            // http
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 443           // https
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ingress {
  #   from_port   = 57050          // orderer
  #   to_port     = 57050
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  #   ingress {
  #   from_port   = 57051          // peer
  #   to_port     = 57051
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  # egress {
  #   from_port   = 7050            // orderer
  #   to_port     = 57050
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  # egress {
  #   from_port   = 7051            // peer
  #   to_port     = 57051
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }
}

##################################################
#  Security Group
##################################################
resource "aws_security_group" "appserver-sg" {
  name        = "appserver-sg"
  description = "Security Group for application servers"
  vpc_id      = "${aws_vpc.vpc.id}"

  ingress {
    from_port   = 22            // nginx-test
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80            // nginx-test
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443           // https
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 57999          // heath check
    to_port     = 57999
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 80            // http
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 443           // https
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ingress {
  #   from_port   = 57050          // orderer
  #   to_port     = 57050
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  # ingress {
  #   from_port   = 57051          // peer
  #   to_port     = 57051
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  # egress {
  #   from_port   = 7050            // orderer
  #   to_port     = 57050
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  egress {
    from_port   = 7051            // peer
    to_port     = 57051
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

    ingress {
    from_port   = 7051            // peer
    to_port     = 57051
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}