#################################################
# Private Subnets
#################################################
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
# Private routing table
#################################################
/**
  * 아무 설정 없이 aws_route_table resource를 생성만 해도
  * ${var.vpc_cidr}로 라우팅하는 기본 설정은 생성된다.
  */
resource "aws_route_table" "private-route-table" {
  vpc_id = "${aws_vpc.vpc.id}"
  
  tags = {
    Name = "private-route-table"
  }
}

resource "aws_route_table_association" "private-route-table-assoc" {
  count          = "${length(var.availability_zones)}"
  route_table_id = "${aws_route_table.public-route-table.id}"
  subnet_id      = "${element(aws_subnet.private-subnet.*.id, count.index)}"
}
