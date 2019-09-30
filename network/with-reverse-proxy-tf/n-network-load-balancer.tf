##############################################################################
# Public Zone Load Balancing
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
    Name = "public-load-balancer"
  }
}

resource "aws_lb_target_group" "public-lb-target-group" {
  name     = "public-lb-target-group"
  port        = 57999
  protocol    = "TCP"
  target_type = "instance"
  vpc_id   = "${aws_vpc.vpc.id}"

  depends_on = [
    "aws_lb.public-load-balancer",
  ]

  tags = {
    Name = "public-lb-target-group"
  }
}

resource "aws_lb_listener" "public-lb-listener" {
  load_balancer_arn = "${aws_lb.public-load-balancer.arn}"
  port              = "57999"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.public-lb-target-group.arn}"
  }
}
