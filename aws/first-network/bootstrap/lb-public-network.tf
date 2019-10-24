##############################################################################
# Public subnet Load Balancer & Listener
##############################################################################
resource "aws_lb" "public-load-balancer" {
  name            = "public-load-balancer"
  internal           = false
  load_balancer_type = "network"

  subnets = [
    "${aws_subnet.public-subnet.0.id}",
    "${aws_subnet.public-subnet.1.id}",
  ]

  tags = {
    Name = "public-network-load-balancer"
  }
}

resource "aws_lb_listener" "public-lb-listener-57999" {
  load_balancer_arn = "${aws_lb.public-load-balancer.arn}"
  port              = "57999"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.public-lb-target-group-57999.arn}"
  }
}

resource "aws_lb_listener" "public-lb-listener-57051" {
  load_balancer_arn = "${aws_lb.public-load-balancer.arn}"
  port              = "57051"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.public-lb-target-group-57051.arn}"
  }
}

resource "aws_lb_listener" "public-lb-listener-57050" {
  load_balancer_arn = "${aws_lb.public-load-balancer.arn}"
  port              = "57050"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.public-lb-target-group-57050.arn}"
  }
}