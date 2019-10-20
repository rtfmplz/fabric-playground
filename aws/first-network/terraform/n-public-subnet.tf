#################################################
# Public Subnets
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