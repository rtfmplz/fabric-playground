locals {
    docker_network="hyperledger"
}

##################################################
# EC2 for admin
##################################################
resource "aws_instance" "admin"{
	ami = "${lookup(var.ecs_ami, var.region)}"
	instance_type = "t2.micro"
	key_name = "${aws_key_pair.ec2_key_pair.key_name}"
	subnet_id = "${aws_subnet.admin-subnet.id}"
	vpc_security_group_ids = ["${aws_security_group.admin-sg.id}"]
	associate_public_ip_address = "true"
}

resource "null_resource" "admin-provisioner" {

	connection {
		type = "ssh"
		user = "ec2-user"
		private_key = "${file(lookup(var.ec2_key_path, "private"))}"
		host = "${aws_instance.admin.public_ip}"
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
	 	"pushd /tmp ; docker-compose -f /tmp/admin.yaml up -d ; popd",
        "chmod +x /tmp/scripts/admin.sh; docker exec cli ./scripts/admin.sh",
    	] 
	}
}
