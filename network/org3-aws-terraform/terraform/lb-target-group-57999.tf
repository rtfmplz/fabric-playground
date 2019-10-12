##############################################################################
# Target group for 57999 port
##############################################################################
resource "aws_lb_target_group" "public-lb-target-group-57999" {
  name     = "public-lb-target-group-57999"
  port        = 57999
  protocol    = "TCP"
  target_type = "instance"
  vpc_id   = "${aws_vpc.vpc.id}"

  depends_on = [
    "aws_lb.public-load-balancer",
  ]

  tags = {
    Name = "public-lb-target-group-57999"
  }
}

resource "aws_lb_target_group_attachment" "attach-gw0-57999" {
  target_group_arn = "${aws_lb_target_group.public-lb-target-group-57999.arn}"
  port = 57999
  target_id = "${aws_instance.gw0.id}"
}

resource "aws_lb_target_group_attachment" "attach-gw1-57999" {
  target_group_arn = "${aws_lb_target_group.public-lb-target-group-57999.arn}"
  port = 57999
  target_id = "${aws_instance.gw1.id}"
}
