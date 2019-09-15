##################################################
# ECS INSTANCE ROLE
##################################################
resource "aws_iam_role" "ecs-instance-role" {
  name               = "ecs-instance-role"
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
  assume_role_policy = "${data.aws_iam_policy_document.ecs-instance-policy.json}"
}

data "aws_iam_policy_document" "ecs-instance-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# ECS 컨테이너 인스턴스용 IAM 정책
# 이 정책에는 ECS, ECRElastic Container Registry 관련 권한과 로그 기록을 위한 권한이 부여
# 이러한 권한들은 주로 ECS 컨테이너 에이전트에서 클러스터 관련 작업을 수행하기 위해 사용
resource "aws_iam_role_policy_attachment" "ecs-instance-role-attachment" {
  role       = "${aws_iam_role.ecs-instance-role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

# 뭔지 잘 모르겠다..
resource "aws_iam_instance_profile" "ecs-instance-profile" {
  name = "ecs-instance-profile"
  path = "/"
  role = "${aws_iam_role.ecs-instance-role.id}"

  provisioner "local-exec" {
    command = "sleep 10"
  }
}
