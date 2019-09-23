##################################################
# Web Servers
# [FIXME] load-balancer 생성에 시간이 오래걸려 테스트를 위해 임시로 주석처리 함
##################################################
resource "aws_ecs_service" "web-server-service" {
  name            = "web-server-service"
  # iam_role        = "${aws_iam_role.ecs-service-role.name}"
  cluster         = "${aws_ecs_cluster.public-ecs-cluster.id}"
  task_definition = "${aws_ecs_task_definition.nginx.family}:${max("${aws_ecs_task_definition.nginx.revision}", "${data.aws_ecs_task_definition.nginx.revision}")}"
  desired_count   = 2 #유지되어야 하는 task_definition의 인스턴스 수

  # load_balancer {
  #   target_group_arn = "${aws_lb_target_group.public-lb-target-group.arn}"
  #   container_port   = 80
  #   container_name   = "nginx"
 # }
}

#################################################
# App Servers
#################################################
resource "aws_ecs_service" "peer-server-service" {
  name            = "peer-server-service"
  cluster         = "${aws_ecs_cluster.private-ecs-cluster.id}"
  task_definition = "${aws_ecs_task_definition.peer.family}:${max("${aws_ecs_task_definition.peer.revision}", "${data.aws_ecs_task_definition.peer.revision}")}"
  scheduling_strategy = "DAEMON"
  placement_constraints {
    type       = "memberOf"
    expression = "attribute:ecs.availability-zone in [ap-northeast-2a]"
  }
}

resource "aws_ecs_service" "peer2-server-service" {
  name            = "peer2-server-service"
  cluster         = "${aws_ecs_cluster.private-ecs-cluster.id}"
  task_definition = "${aws_ecs_task_definition.peer.family}:${max("${aws_ecs_task_definition.peer.revision}", "${data.aws_ecs_task_definition.peer.revision}")}"
  scheduling_strategy = "DAEMON"
  placement_constraints {
    type       = "memberOf"
    expression = "attribute:ecs.availability-zone in [ap-northeast-2c]"
  }
}
