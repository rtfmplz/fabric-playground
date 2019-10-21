##############################################################################
# Target group for 57050 port
##############################################################################
resource "aws_lb_target_group" "public-lb-target-group-57050" {
  name     = "public-lb-target-group-57050"
  port        = 57050
  protocol    = "TCP"
  target_type = "instance"
  vpc_id   = "${aws_vpc.vpc.id}"

  depends_on = [
    "aws_lb.public-load-balancer",
  ]

  tags = {
    Name = "public-lb-target-group-57050"
  }
}

resource "aws_lb_target_group_attachment" "attach-gw0-57050" {
  target_group_arn = "${aws_lb_target_group.public-lb-target-group-57050.arn}"
  port = 57050
  target_id = "${aws_instance.gw0.id}"
}

resource "aws_lb_target_group_attachment" "attach-gw1-57050" {
  target_group_arn = "${aws_lb_target_group.public-lb-target-group-57050.arn}"
  port = 57050
  target_id = "${aws_instance.gw1.id}"
}
