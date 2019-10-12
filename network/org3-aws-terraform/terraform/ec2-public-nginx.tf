##################################################
# EC2 for public subnet 1
##################################################
resource "aws_instance" "gw0"{
	ami = "${lookup(var.ecs_ami, var.region)}"
	instance_type = "t2.micro"
	key_name = "${aws_key_pair.ec2_key_pair.key_name}"
	subnet_id = "${element(aws_subnet.public-subnet.*.id, 0)}"
	vpc_security_group_ids = ["${aws_security_group.public-sg.id}"]
	associate_public_ip_address = "true"
}

##################################################
# EC2 for public subnet 2
##################################################

resource "aws_instance" "gw1"{
	ami = "${lookup(var.ecs_ami, var.region)}"
	instance_type = "t2.micro"
	key_name = "${aws_key_pair.ec2_key_pair.key_name}"
	subnet_id = "${element(aws_subnet.public-subnet.*.id, 1)}"
	vpc_security_group_ids = ["${aws_security_group.public-sg.id}"]
	associate_public_ip_address = "true"
}

##################################################
# PROVISIONER
##################################################
resource "null_resource" "gw0-provisioner" {

    connection {
      type = "ssh"
      user = "ec2-user"
      private_key = "${file(lookup(var.ec2_key_path, "private"))}"
      host = "${aws_instance.gw0.public_ip}"
    }

	provisioner "file" {
		source = "./resources/nginx/"
	 	destination = "/tmp/"
	}

	provisioner "remote-exec" {
		inline = [
			"echo SELF_PRIVATE_IP=${aws_instance.gw0.private_ip} >> /tmp/.env" ,
			# 실제 ORG1의 IP로 변경되어야 함
			"echo ORG1_GW_IP=${aws_instance.gw0.private_ip} >> /tmp/.env" ,
			"echo ORG1_GW_IP=${aws_instance.gw0.private_ip} >> /tmp/.env" ,
			"echo VM0_PRIV_IP=${aws_instance.vm0.private_ip} >> /tmp/.env" ,
			"echo VM1_PRIV_IP=${aws_instance.vm1.private_ip} >> /tmp/.env" ,
			"sudo curl -L \"https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)\" -o /usr/local/bin/docker-compose",
			"sudo chmod +x /usr/local/bin/docker-compose",
			"sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose",
	 		"cd /tmp; docker-compose -f /tmp/docker-compose.yaml up -d",
		]
	}
}

resource "null_resource" "gw1-provisioner" {
  
    connection {
      type = "ssh"
      user = "ec2-user"
      private_key = "${file(lookup(var.ec2_key_path, "private"))}"
      host = "${aws_instance.gw1.public_ip}"
    }

	provisioner "file" {
		source = "./resources/nginx/"
	 	destination = "/tmp/"
	}

	provisioner "remote-exec" {
		inline = [
			"echo SELF_PRIVATE_IP=${aws_instance.gw1.private_ip} >> /tmp/.env" ,
			# 실제 ORG1의 IP로 변경되어야 함
			"echo ORG1_GW_IP=${aws_instance.gw1.private_ip} >> /tmp/.env" ,
			"echo ORG1_GW_IP=${aws_instance.gw1.private_ip} >> /tmp/.env" ,
			"echo VM0_PRIV_IP=${aws_instance.vm0.private_ip} >> /tmp/.env" ,
			"echo VM1_PRIV_IP=${aws_instance.vm1.private_ip} >> /tmp/.env" ,
			"sudo curl -L \"https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)\" -o /usr/local/bin/docker-compose",
			"sudo chmod +x /usr/local/bin/docker-compose",
			"sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose",
	 		"cd /tmp; docker-compose -f /tmp/docker-compose.yaml up -d",
		]
	}
}
