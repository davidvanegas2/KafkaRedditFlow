resource "aws_instance" "reddit_producer_instance" {
  ami                    = "ami-066a7fbea5161f451"
  instance_type          = var.instance_type
  key_name               = var.key_pair_name
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.ec2_public_sg.id]

  associate_public_ip_address = true

  tags = {
    Name = "reddit-streaming-producer"
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              curl -LsSf https://astral.sh/uv/install.sh | sh
              source $HOME/.cargo/env
              EOF
}
