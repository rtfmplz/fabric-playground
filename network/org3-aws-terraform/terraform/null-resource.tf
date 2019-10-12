locals {
    docker_network="hyperledger"
}

resource "null_resource" "provisioner0" {

  provisioner "remote-exec" {
    inline = [
      "echo ORG1_GW_IP=${aws_instance.gateway0.private_ip} >> /tmp/.env" ,
      "echo ORG1_GW_IP=${aws_instance.gateway1.private_ip} >> /tmp/.env" ,
      "echo VM0_PRIV_IP=${aws_instance.vm0.private_ip} >> /tmp/.env" ,
      "echo VM1_PRIV_IP=${aws_instance.vm1.private_ip} >> /tmp/.env" ,
    ]
		
    connection {
      type = "ssh"
      user = "ec2-user"
      private_key = "${file("~/.ssh/id_rsa")}"
      host = "${aws_instance.vm0.public_ip}"
    }
  }
}
resource "null_resource" "provisioner1" {

  provisioner "remote-exec" {
    inline = [
      "echo ORG1_GW_IP=${aws_instance.gateway0.private_ip} >> /tmp/.env" ,
      "echo ORG1_GW_IP=${aws_instance.gateway1.private_ip} >> /tmp/.env" ,
      "echo VM0_PRIV_IP=${aws_instance.vm0.private_ip} >> /tmp/.env" ,
      "echo VM1_PRIV_IP=${aws_instance.vm1.private_ip} >> /tmp/.env" ,
    ]
		
    connection {
      type = "ssh"
      user = "ec2-user"
      private_key = "${file("~/.ssh/id_rsa")}"
      host = "${aws_instance.vm1.public_ip}"
    }
  }
}
resource "null_resource" "provisioner2" {

  provisioner "remote-exec" {
    inline = [
      "echo ORG1_GW_IP=${aws_instance.gateway0.private_ip} >> /tmp/.env" ,
      "echo ORG1_GW_IP=${aws_instance.gateway1.private_ip} >> /tmp/.env" ,
      "echo VM0_PRIV_IP=${aws_instance.vm0.private_ip} >> /tmp/.env" ,
      "echo VM1_PRIV_IP=${aws_instance.vm1.private_ip} >> /tmp/.env" ,
    ]
		
    connection {
      type = "ssh"
      user = "ec2-user"
      private_key = "${file("~/.ssh/id_rsa")}"
      host = "${aws_instance.gateway0.public_ip}"
    }
  }
}
resource "null_resource" "provisioner3" {

  provisioner "remote-exec" {
    inline = [
      "echo ORG1_GW_IP=${aws_instance.gateway0.private_ip} >> /tmp/.env" ,
      "echo ORG1_GW_IP=${aws_instance.gateway1.private_ip} >> /tmp/.env" ,
      "echo VM0_PRIV_IP=${aws_instance.vm0.private_ip} >> /tmp/.env" ,
      "echo VM1_PRIV_IP=${aws_instance.vm1.private_ip} >> /tmp/.env" ,
    ]
		
    connection {
      type = "ssh"
      user = "ec2-user"
      private_key = "${file("~/.ssh/id_rsa")}"
      host = "${aws_instance.gateway0.public_ip}"
    }
  }
}
