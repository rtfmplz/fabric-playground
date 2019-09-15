##################################################
# nginx task definition
##################################################
data "aws_ecs_task_definition" "nginx" {
  task_definition = "${aws_ecs_task_definition.nginx.family}"
}

resource "aws_ecs_task_definition" "nginx" {
  family = "nginx"

  container_definitions = <<DEFINITION
  [
    {
        "name": "nginx",
        "image": "nginx:latest",
        "memory": 256,
        "cpu": 256,
        "essential": true,
        "portMappings": [
          {
            "containerPort": 80,
            "hostPort": 80,
            "protocol": "tcp"
          }
        ]
    }
  ]
  DEFINITION
}

##################################################
# peer task definition
##################################################
data "aws_ecs_task_definition" "peer" {
  task_definition = "${aws_ecs_task_definition.peer.family}"
}

resource "aws_ecs_task_definition" "peer" {
  family = "peer"

  container_definitions = <<DEFINITION
  [
    {
        "name": "peer",
        "image": "hyperledger/fabric-peer",
        "memory": 256,
        "cpu": 256,
        "essential": true,
        "portMappings": [
          {
            "containerPort": 8080,
            "hostPort": 8080,
            "protocol": "tcp"
          }
        ]
    }
  ]
  DEFINITION
}

##################################################
# couchdb task definition
##################################################


##################################################
# fabric-ca task definition
##################################################