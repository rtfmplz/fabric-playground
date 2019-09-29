##################################################
# EC2 for public subnet 1
##################################################
resource "aws_instance" "gateway0"{
	ami = "${lookup(var.ecs_ami, var.region)}"
	instance_type = "t2.micro"
	key_name = "${aws_key_pair.ec2_key_pair.key_name}"
	subnet_id = "${element(aws_subnet.public-subnet.*.id, 0)}"
	vpc_security_group_ids = ["${aws_security_group.public-sg.id}"]
	associate_public_ip_address = "true"

	user_data = "${file(lookup(var.resources_path, "public-user-data"))}"

	# provisioner "file" {
	# 	source = "./resources/docker-compose.yaml"
	# 	destination = "/tmp/docker-compose.yaml"

	# 	connection {
	# 		type = "ssh"
	# 		user = "ec2-user"
	# 		private_key = "${file(lookup(var.ec2_key_path, "private"))}"
	# 		host = "${self.public_ip}"
	# 	}
	# }

	# provisioner "remote-exec" {
	# 	inline = [
	# 		"echo ${self.private_ip} > /tmp/.env" ,
	# 		"docker-compose -f /tmp/docker-compose.yaml up",
	# 	]
		
	# 	connection {
	# 		type = "ssh"
	# 		user = "ec2-user"
	# 		private_key = "${file(lookup(var.ec2_key_path, "private"))}"
	# 		host = "${self.public_ip}"
	# 	}
	# }
}

##################################################
# EC2 for public subnet 2
##################################################

resource "aws_instance" "gateway1"{
	ami = "${lookup(var.ecs_ami, var.region)}"
	instance_type = "t2.micro"
	key_name = "${aws_key_pair.ec2_key_pair.key_name}"
	subnet_id = "${element(aws_subnet.public-subnet.*.id, 1)}"
	vpc_security_group_ids = ["${aws_security_group.public-sg.id}"]
	associate_public_ip_address = "true"


	# user_data = "${file(lookup(var.resources_path, "public-user-data"))}"

	# provisioner "file" {
	# 	source = "./resources/docker-compose.yaml"
	# 	destination = "/tmp/docker-compose.yaml"

	# 	connection {
	# 		type = "ssh"
	# 		user = "ec2-user"
	# 		private_key = "${file(lookup(var.ec2_key_path, "private"))}"
	# 		host = "${self.public_ip}"
	# 	}
	# }

	# provisioner "remote-exec" {
	# 	inline = [
	# 		"echo ${self.private_ip} > /tmp/.env" ,
	# 		"docker-compose -f /tmp/docker-compose.yaml up",
	# 	]
		
	# 	connection {
	# 		type = "ssh"
	# 		user = "ec2-user"
	# 		private_key = "${file(lookup(var.ec2_key_path, "private"))}"
	# 		host = "${self.public_ip}"
	# 	}
	# }
}