############################################################################
# AWS Configuration                                                        #
############################################################################


variable "admin_ec2_public_ip" {
  type = "string"
  description = "admin_ec2_public_ip"
}

variable "ec2_key_pair_name" {
  description = "EC2 instance key pair name"
  default = "KP101"
}

variable "ec2_key_path" {
  type = "map"
  default = {
    public    = "~/.ssh/id_rsa.pub"
    private   = "~/.ssh/id_rsa"
  }
}