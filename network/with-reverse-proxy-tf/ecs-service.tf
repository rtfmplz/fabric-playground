
##################################################
# Web Servers
##################################################
resource "aws_ecs_service" "web-server-service" {
  name            = "web-server-service"
  iam_role        = "${aws_iam_role.ecs-service-role.name}"
  cluster         = "${aws_ecs_cluster.public-ecs-cluster.id}"
  task_definition = "${aws_ecs_task_definition.nginx.family}:${max("${aws_ecs_task_definition.nginx.revision}", "${data.aws_ecs_task_definition.nginx.revision}")}"
  desired_count   = 2

  load_balancer {
    target_group_arn = "${aws_lb_target_group.public-lb-target-group.arn}"
    container_port   = 80
    container_name   = "nginx"
  }
}

##################################################
# App Servers
##################################################
# resource "aws_ecs_service" "tomcat-server-service" {
#   name            = "tomcat-server-service"
#   iam_role        = "${aws_iam_role.ecs-service-role.name}"
#   cluster         = "${aws_ecs_cluster.private-ecs-cluster.id}"
#   task_definition = "${aws_ecs_task_definition.tomcat.family}:${max("${aws_ecs_task_definition.tomcat.revision}", "${data.aws_ecs_task_definition.tomcat.revision}")}"
#   desired_count   = 2

#   load_balancer {
#     target_group_arn = "${aws_lb_target_group.appservers-lb-target-group.arn}"
#     container_port   = 8080
#     container_name   = "tomcat-webserver"
#   }
# }
