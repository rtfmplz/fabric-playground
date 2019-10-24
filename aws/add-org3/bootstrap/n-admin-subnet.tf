#################################################
# admin Subnets
#################################################
resource "aws_subnet" "admin-subnet" {
  cidr_block        = "${var.admin_subnets}"
  vpc_id            = "${aws_vpc.vpc.id}"
  availability_zone = "${var.availability_zones[0]}"

  tags = {
    Name = "admin-subnet"
  }
}

#################################################
# admin routing table
#################################################
/**
  * 아무 설정 없이 aws_route_table resource를 생성만 해도
  * ${var.vpc_cidr}로 라우팅하는 기본 설정은 생성된다.
  */
resource "aws_route_table" "admin-route-table" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }

  tags = {
    Name = "admin-route-table"
  }
}

resource "aws_route_table_association" "admin-route-table-assoc" {
  count          = "${length(var.availability_zones)}"
  route_table_id = "${aws_route_table.admin-route-table.id}"
  subnet_id      = "${aws_subnet.admin-subnet.id}"
}
