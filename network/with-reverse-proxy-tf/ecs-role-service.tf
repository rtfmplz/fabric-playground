##################################################
# ECS SERVICE ROLE
##################################################
resource "aws_iam_role" "ecs-service-role" {
  name               = "ecs-service-role"
  path               = "/"
  # 역할을 맡을수 있는 권한을 엔티티에 부여하는 정책, 아래 Json 형태로도 추가할 수 있다.
  # assume_role_policy = <<EOF
  # {
  #   "Statement": [
  #     {
  #       "Action": "sts:AssumeRole",
  #       "Principal": {
  #         "Service": "ec2.amazonaws.com"
  #       },
  #       "Effect": "Allow",
  #       "Sid": ""
  #     }
  #   ]
  # }
  # EOF
  assume_role_policy = "${data.aws_iam_policy_document.ecs-service-policy.json}"
}

data "aws_iam_policy_document" "ecs-service-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs.amazonaws.com"]
    }
  }
}

# ELB(Elastic Load Balancer)와 연동하는 경우에 AmazonEC2ContainerServiceRole 권한이 필요.
# 주로 컨테이너를 동적으로 로드 밸런서에 추가하고 제거할 때 필요한 권한들이 포함되어 있다.
resource "aws_iam_role_policy_attachment" "ecs-service-role-attachment" {
  role       = "${aws_iam_role.ecs-service-role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}


