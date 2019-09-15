region = "ap-northeast-2"

vpc_name = "test_vpc"

vpc_cidr = "192.168.0.0/16"

# ap-northeast-2b에서는 t2.micro instance type 이 지원되지 않음
availability_zones = ["ap-northeast-2a", "ap-northeast-2c"]

private_subnets = ["192.168.1.0/24", "192.168.2.0/24"]

public_subnets = ["192.168.101.0/24", "192.168.102.0/24"]

ec2_key_pair_name="KP101"

ecs_ami = {
  us-east-2      = "ami-64300001"
  us-east-1      = "ami-aff65ad2"
  us-west-2      = "ami-40ddb938"
  us-west-1      = "ami-69677709"
  eu-west-2      = "ami-2218f945"
  eu-west-3      = "ami-250eb858"
  eu-west-1      = "ami-2d386654"
  eu-central-1   = "ami-9fc39c74"
  ap-northeast-2 = "ami-000fbda700ba8fe9d"
  ap-northeast-1 = "ami-a99d8ad5"
  ap-southeast-2 = "ami-efda148d"
  ap-southeast-1 = "ami-846144f8"
  ca-central-1   = "ami-897ff9ed"
  ap-south-1     = "ami-72edc81d"
  sa-east-1      = "ami-4a7e2826"
}


