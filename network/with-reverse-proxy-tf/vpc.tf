#################################################
# VPC
# - 본 예제에서 NACL는 생성하지 않았는데, 기본으로 생성된다.
#################################################
resource "aws_vpc" "vpc" {
  cidr_block = "${var.vpc_cidr}"

  tags = {
    Name = "main-vpc"
  }
}

#################################################
# subnets
#################################################
resource "aws_subnet" "public-subnet" {
  count                   = "${length(var.availability_zones)}"
  cidr_block              = "${var.public_subnets[count.index]}"
  vpc_id                  = "${aws_vpc.vpc.id}"
  map_public_ip_on_launch = "true"
  availability_zone       = "${var.availability_zones[count.index]}"

  tags = {
    Name = "public-subnet-${count.index}"
  }
}

resource "aws_subnet" "private-subnet" {
  count             = "${length(var.availability_zones)}"
  cidr_block        = "${var.private_subnets[count.index]}"
  vpc_id            = "${aws_vpc.vpc.id}"
  availability_zone = "${var.availability_zones[count.index]}"

  tags = {
    Name = "private-subnet-${count.index}"
  }
}

#################################################
# gateways
#################################################
resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags = {
    Name = "igw"
  }
}


/**
 * NAT 게이트웨이는 프라이빗 서브넷이 인터넷과 통신하기위한 아웃바운드 인스턴스이다.
 * NAT 게이트웨이는 프라이빗 서브넷에서 외부로 요청하는 아웃바운드 트래픽을 받아 인터넷게이트웨이와 연결한다.
 * 프라이빗 네트워크는 외부에서 요청되는 인바운드는 필요없지만, 인스턴스의 업데이트등을 위해서 아웃바운드 트래픽을 허용해야 하는 경우가 있다.
 * 본 예제에서는 프라이빗 네트워크에 포함되는 Hyperledger Fabric 인스턴스들은 외부와 통신을 완전히 차단하기위해서 NAT 게이트웨이는 제거한다.
 */

# resource "aws_nat_gateway" "ngw" {
#   allocation_id = "${aws_eip.ngw-eip.id}"
#   subnet_id     = "${element(aws_subnet.public-subnet.*.id, 0)}"
#   tags = {
#     Name = "ngw"
#   }
# }

# resource "aws_eip" "ngw-eip" {
#   vpc = "true"
# }

#################################################
# public routing table
#################################################
resource "aws_route_table" "public-route-table" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "public-route-table-assoc" {
  count          = "${length(var.availability_zones)}"
  route_table_id = "${aws_route_table.public-route-table.id}"
  subnet_id      = "${element(aws_subnet.public-subnet.*.id, count.index)}"
}

#################################################
# private routing table
#################################################
/**
  * 아무 설정 없이 aws_route_table resource를 생성만 해도
  * ${var.vpc_cidr}로 라우팅하는 기본 설정은 생성된다.
  * 
  * 아래 NAT 게이트웨이와 이어주는 부분은 주석 처리 함
  */
resource "aws_route_table" "private-route-table" {
  vpc_id = "${aws_vpc.vpc.id}"

  # [FIXME] 구현 중 ssh 접근을 통한 정상 동작 확인을 위해서 임시로 설정
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }

  tags = {
    Name = "private-route-table"
  }
}

resource "aws_route_table_association" "private-route-table-assoc" {
  count          = "${length(var.availability_zones)}"
  route_table_id = "${aws_route_table.private-route-table.id}"
  subnet_id      = "${element(aws_subnet.private-subnet.*.id, count.index)}"
}

# resource "aws_route" "private-route" {
#   route_table_id         = "${aws_route_table.private-route-table.id}"
#   destination_cidr_block = "0.0.0.0/0"
#   nat_gateway_id         = "${aws_nat_gateway.ngw.id}"
# }

