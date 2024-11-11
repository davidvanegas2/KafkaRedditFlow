variable "instance_type" {
  type        = string                     # The type of the variable, in this case a string
  default     = "t2.xlarge"                 # Default value for the variable
  description = "The type of EC2 instance" # Description of what this variable represents
}

variable "key_pair_name" {
  type        = string
  description = "The name of the key pair to use for the EC2 instance"
}

variable "my_ip" {
  type        = string
  description = "The IP address to allow SSH access from"
}
