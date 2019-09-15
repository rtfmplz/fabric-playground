##################################################
# ECS Cluster
# 
# - lookup(map, key, default)
##################################################
resource "aws_ecs_cluster" "public-ecs-cluster" {
  name = "${lookup(var.ecs_cluster_names, "public")}"
}

resource "aws_ecs_cluster" "private-ecs-cluster" {
  name = "${lookup(var.ecs_cluster_names, "private")}"
}
