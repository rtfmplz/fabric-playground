##################################################
# EC2 for private subnet 1
##################################################
resource "aws_instance" "vm0"{
	ami = "${lookup(var.ecs_ami, var.region)}"
	instance_type = "t2.micro"
	key_name = "${aws_key_pair.ec2_key_pair.key_name}"
	subnet_id = "${element(aws_subnet.private-subnet.*.id, 0)}"
	vpc_security_group_ids = ["${aws_security_group.private-sg.id}"]
	associate_public_ip_address = "true"
}

##################################################
# EC2 for private subnet 2
##################################################

resource "aws_instance" "vm1"{
	ami = "${lookup(var.ecs_ami, var.region)}"
	instance_type = "t2.large"
	key_name = "${aws_key_pair.ec2_key_pair.key_name}"
	subnet_id = "${element(aws_subnet.private-subnet.*.id, 1)}"
	vpc_security_group_ids = ["${aws_security_group.private-sg.id}"]
	associate_public_ip_address = "true"
}

##################################################
# PROVISIONER
##################################################
resource "null_resource" "vm0-provisioner" {

	connection {
		type = "ssh"
		user = "ec2-user"
		private_key = "${file(lookup(var.ec2_key_path, "private"))}"
		host = "${aws_instance.vm0.public_ip}"
	}

	provisioner "file" {
		source = "./resources/hyperledger/"
		destination = "/tmp/"
	}

	provisioner "remote-exec" {
		inline = [
			"echo GW0_PRIV_IP=${aws_instance.gw0.private_ip} >> /tmp/.env" ,
			"echo GW1_PRIV_IP=${aws_instance.gw1.private_ip} >> /tmp/.env" ,
			"echo VM0_PRIV_IP=${aws_instance.vm0.private_ip} >> /tmp/.env" ,
			"echo VM1_PRIV_IP=${aws_instance.vm1.private_ip} >> /tmp/.env" ,
			"sudo curl -L \"https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)\" -o /usr/local/bin/docker-compose",
			"sudo chmod +x /usr/local/bin/docker-compose",
			"sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose",
			"docker network create ${var.docker_network}",
			"echo DOCKER_NETWORK=${var.docker_network} >> /tmp/.env",
			"sudo docker pull hyperledger/fabric-ccenv:latest",
			"sudo docker pull hyperledger/fabric-javaenv:latest",
			"sudo docker pull hyperledger/fabric-baseos:amd64-0.4.18",
			"pushd /tmp ; docker-compose -f /tmp/vm0.yaml up -d ; popd",
		]
	}
}

resource "null_resource" "vm1-provisioner" {

	connection {
		type = "ssh"
		user = "ec2-user"
		private_key = "${file(lookup(var.ec2_key_path, "private"))}"
		host = "${aws_instance.vm1.public_ip}"
	}

	provisioner "file" {
		source = "./resources/hyperledger/"
		destination = "/tmp/"
	}

	provisioner "remote-exec" {
		inline = [
			"echo GW0_PRIV_IP=${aws_instance.gw0.private_ip} >> /tmp/.env" ,
			"echo GW1_PRIV_IP=${aws_instance.gw1.private_ip} >> /tmp/.env" ,
			"echo VM0_PRIV_IP=${aws_instance.vm0.private_ip} >> /tmp/.env" ,
			"echo VM1_PRIV_IP=${aws_instance.vm1.private_ip} >> /tmp/.env" ,
			"sudo curl -L \"https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)\" -o /usr/local/bin/docker-compose",
			"sudo chmod +x /usr/local/bin/docker-compose",
			"sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose",
			"docker network create ${var.docker_network}",
			"echo DOCKER_NETWORK=${var.docker_network} >> /tmp/.env",
			"sudo docker pull hyperledger/fabric-ccenv:latest",
			"sudo docker pull hyperledger/fabric-javaenv:latest",
			"sudo docker pull hyperledger/fabric-baseos:amd64-0.4.18",
			"pushd /tmp ; docker-compose -f /tmp/vm1.yaml up -d ; popd",
    	] 
	}
}