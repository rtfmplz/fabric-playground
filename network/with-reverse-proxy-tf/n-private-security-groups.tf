##################################################
# Private Security Group
# 
# 보안 그룹은 인스턴스에 대한 인바운드 및 아웃바운드 트래픽을 제어하는 가상 방화벽 역할을 한다.
# VPC에서 인스턴스를 시작할 때 최대 5개의 보안 그룹에 인스턴스를 할당할 수 있다. 
# 보안 그룹은 서브넷 수준이 아니라 인스턴스 수준에서 작동하므로 VPC에 있는 서브넷의 각 인스턴스를 서로 다른 보안 그룹 세트에 할당할 수 있다.
# 시작할 때 특정 그룹을 지정하지 않으면 인스턴스가 자동으로 VPC의 기본 보안 그룹에 할당된다.
##################################################
resource "aws_security_group" "private-sg" {
  name        = "private-sg"
  description = "Security Group for hyperledger-fabric"
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
    # cidr_blocks = "${var.public_subnets}"
  }
  
  ingress {
    description = "for peer"
    from_port   = 7050
    to_port     = 7050
    protocol    = "tcp"
    cidr_blocks = "${var.public_subnets}"
  }

  ##################################################
  # outbound
  ##################################################
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
    description = "for peer in other organization, other subnet"
    from_port   = 7050
    to_port     = 7050
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "for orderer in other organization"
    from_port   = 7051
    to_port     = 7051
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

