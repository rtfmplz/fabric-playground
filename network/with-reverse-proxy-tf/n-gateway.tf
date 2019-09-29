#################################################
# Internet Gateways
#################################################
resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags = {
    Name = "igw"
  }
}

#################################################
# NAT Gateways
#################################################
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