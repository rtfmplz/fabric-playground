##################################################
# KEY PAIR for EC2 SSH
##################################################
resource "aws_key_pair" "ec2_key_pair" {
  key_name = "${var.ec2_key_pair_name}"
  # ssh-keygen -t rsa -b 4096 -C "kjlee.ko@gmail.com" -f "$HOME/.ssh/id_rsa" -N ""
  public_key = "${file(lookup(var.ec2_key_path, "public"))}"
}