locals {
    docker_network="hyperledger"
}

##################################################
# EC2 for private subnet 1
##################################################
resource "aws_instance" "manager"{
	ami = "${lookup(var.ecs_ami, var.region)}"
	instance_type = "t2.micro"
	key_name = "${aws_key_pair.ec2_key_pair.key_name}"
	subnet_id = "${element(aws_subnet.private-subnet.*.id, 0)}"
	vpc_security_group_ids = ["${aws_security_group.private-sg.id}"]
	associate_public_ip_address = "true"

	user_data = "${file(lookup(var.resources_path, "private-user-data"))}"

	provisioner "file" {
		source = "./resources/hyperledger/"
		destination = "/tmp/"

		connection {
	 		type = "ssh"
	 		user = "ec2-user"
	 		private_key = "${file("~/.ssh/id_rsa")}"
	 		host = "${self.public_ip}"
	 	}
	}

	provisioner "remote-exec" {
		inline = [
			"echo ORG1_GW_IP=${aws_instance.gateway0.private_ip} >> /tmp/.env" ,
	 		"echo ORG1_GW_IP=${aws_instance.gateway1.private_ip} >> /tmp/.env" ,
	 		"echo VM0_PRIV_IP=${aws_instance.vm0.private_ip} >> /tmp/.env" ,
	 		"echo VM1_PRIV_IP=${aws_instance.vm1.private_ip} >> /tmp/.env" ,
			# permission 없음으로 scp 불가.... 
			# ssh-keygen으로 key 만들어서 priv-key는 manager에 pub-key는 vm에 넣어줘야 할 듯.. role로 해결이 안될까??..
			# "scp /tmp/.env ec2-user@${aws_instance.vm0.private_ip}:/tmp/.env",
			# "scp /tmp/.env ec2-user@${aws_instance.vm1.private_ip}:/tmp/.env",
			"sudo curl -L \"https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)\" -o /usr/local/bin/docker-compose",
			"sudo chmod +x /usr/local/bin/docker-compose",
			"sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose",
            "docker network create ${local.docker_network}",
            "echo DOCKER_NETWORK=${local.docker_network} >> /tmp/.env",
	 		"pushd /tmp ; docker-compose -f /tmp/manager.yaml up -d ; popd",
	 	]
		
	 	connection {
	 		type = "ssh"
	 		user = "ec2-user"
	 		private_key = "${file("~/.ssh/id_rsa")}"
	 		host = "${self.public_ip}"
	 	}
	}
}
