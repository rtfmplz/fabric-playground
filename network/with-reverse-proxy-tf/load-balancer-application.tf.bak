resource "aws_lb" "public-load-balancer" {
  name            = "public-load-balancer"
  security_groups = ["${aws_security_group.public-lb-sg.id}"]

  subnets = [
    "${aws_subnet.public-subnet.0.id}",
    "${aws_subnet.public-subnet.1.id}",
  ]
}

resource "aws_lb_target_group" "public-lb-target-group" {
  name     = "public-lb-target-group"
  port     = "80"
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.vpc.id}"

  health_check {
    healthy_threshold   = "5"
    unhealthy_threshold = "2"
    interval            = "30"
    matcher             = "200"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = "5"
  }

  depends_on = [
    "aws_lb.public-load-balancer",
  ]

  tags = {
    Name = "public-lb-target-group"
  }
}

resource "aws_lb_listener" "public-lb-listener" {
  load_balancer_arn = "${aws_lb.public-load-balancer.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_lb_target_group.public-lb-target-group.arn}"
    type             = "forward"
  }
}
