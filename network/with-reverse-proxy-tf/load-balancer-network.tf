# load-balancer-application은 정상 동작하는데.. 이건 400 error가 난다... 확인 필요!!


##############################################################################
# PUBLIC Zone Load Balancing
##############################################################################
resource "aws_lb" "public-load-balancer" {
  name            = "public-load-balancer"
  internal           = false
  load_balancer_type = "network"
  # LB에 할당 할 보안 그룹 ID 목록. 애플리케이션 유형의 로드 밸런서에만 유효합니다.
  #security_groups = ["${aws_security_group.public-lb-sg.id}"]
  subnets = [
    "${aws_subnet.public-subnet.0.id}",
    "${aws_subnet.public-subnet.1.id}",
  ]
}

# aws_ecs_service의 load_balancer block을 설정해줌으로써 ecs에 의해 자동으로 생성되는 instance들도 연결되게 된다.
resource "aws_lb_target_group" "public-lb-target-group" {
  name     = "public-lb-target-group"
  port        = 80
  protocol    = "TCP"
  target_type = "instance"
  vpc_id   = "${aws_vpc.vpc.id}"

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    port                = "traffic-port"
    protocol            = "TCP"
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
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.public-lb-target-group.arn}"
  }
}
