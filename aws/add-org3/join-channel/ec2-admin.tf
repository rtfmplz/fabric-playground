locals {
    docker_network="hyperledger"
}

##################################################
# EC2 for admin
##################################################
resource "null_resource" "add-org3-provisioner" {

	connection {
		type = "ssh"
		user = "ec2-user"
		private_key = "${file(lookup(var.ec2_key_path, "private"))}"
		host = "${var.admin_ec2_public_ip}"
	}

	provisioner "file" {
		source = "./join-channel.sh"
		destination = "/tmp/join-channel.sh"
	}

	provisioner "remote-exec" {
		inline = [
        "chmod +x /tmp/join-channel.sh; docker exec cli ./join-channel.sh",
    	] 
	}
}
