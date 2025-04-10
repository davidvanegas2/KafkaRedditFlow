resource "aws_iam_instance_profile" "ec2_kafka_producer_profile" {
  name = "ec2-kafka-producer-profile"
  role = aws_iam_role.ec2_kafka_producer_role.name
}

resource "aws_instance" "reddit_producer_instance" {
  depends_on = [aws_msk_cluster.kafka_cluster]

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

  iam_instance_profile = aws_iam_instance_profile.ec2_kafka_producer_profile.name
}
