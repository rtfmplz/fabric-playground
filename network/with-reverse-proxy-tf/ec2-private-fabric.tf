##################################################
# EC2 for private subnet 1
##################################################
resource "aws_instance" "fabric0"{
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
	 		"echo ${self.private_ip} > /tmp/.env" ,
			"sudo curl -L \"https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)\" -o /usr/local/bin/docker-compose",
			"sudo chmod +x /usr/local/bin/docker-compose",
			"sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose",
	 		"docker-compose -f /tmp/docker-compose.yaml up -d",
	 	]
		
	 	connection {
	 		type = "ssh"
	 		user = "ec2-user"
	 		private_key = "${file("~/.ssh/id_rsa")}"
	 		host = "${self.public_ip}"
	 	}
	}
}

##################################################
# EC2 for private subnet 2
##################################################

resource "aws_instance" "fabric1"{
	ami = "${lookup(var.ecs_ami, var.region)}"
	instance_type = "t2.micro"
	key_name = "${aws_key_pair.ec2_key_pair.key_name}"
	subnet_id = "${element(aws_subnet.private-subnet.*.id, 1)}"
	vpc_security_group_ids = ["${aws_security_group.private-sg.id}"]
	associate_public_ip_address = "true"

	user_data = "${file(lookup(var.resources_path, "private-user-data"))}"

	provisioner "file" {
	 	source = "./resources/hyperledger/"
	 	destination = "/tmp/"

	 	connection {
	 		type = "ssh"
	 		user = "ec2-user"
	 		private_key = "${file(lookup(var.ec2_key_path, "private"))}"
	 		host = "${self.public_ip}"
	 	}
	}

	provisioner "remote-exec" {
	 	inline = [
	 		"echo ${self.private_ip} > /tmp/.env" ,
			"sudo curl -L \"https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)\" -o /usr/local/bin/docker-compose",
			"sudo chmod +x /usr/local/bin/docker-compose",
			"sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose",
	 		"docker-compose -f /tmp/docker-compose.yaml up -d",
	 	]
		
	 	connection {
	 		type = "ssh"
	 		user = "ec2-user"
	 		private_key = "${file(lookup(var.ec2_key_path, "private"))}"
	 		host = "${self.public_ip}"
	 	}
	}
}
