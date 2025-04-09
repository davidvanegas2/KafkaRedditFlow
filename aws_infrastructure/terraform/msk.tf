resource "aws_msk_configuration" "kafka_configuration" {
  name = "msk-configuration"

  kafka_versions = ["3.6.0"]

  server_properties = <<EOF
auto.create.topics.enable=true
default.replication.factor=2
delete.topic.enable=true
allow.everyone.if.no.acl.found=false
EOF
}

resource "aws_msk_cluster" "kafka_cluster" {
  cluster_name = "example-msk-cluster"

  kafka_version          = "3.6.0"
  number_of_broker_nodes = 2 # Minimizing broker nodes to reduce cost.

  broker_node_group_info {
    instance_type = "kafka.m7g.large" # Choose the smallest instance type available

    client_subnets = [
      aws_subnet.msk_subnet_1.id,
      aws_subnet.msk_subnet_2.id
    ]

    security_groups = [
      aws_security_group.msk_sg.id
    ]

    storage_info {
      ebs_storage_info {
        volume_size = 5
        provisioned_throughput {
          enabled = false
        }
      }
    }

    connectivity_info {
      vpc_connectivity {
        client_authentication {
          sasl {
            iam   = true
            scram = false
          }
          tls = false
        }
      }
    }
  }

  client_authentication {
    sasl {
      iam   = true
      scram = false
    }
  }

  configuration_info {
    arn      = aws_msk_configuration.kafka_configuration.arn
    revision = aws_msk_configuration.kafka_configuration.latest_revision
  }

  enhanced_monitoring = "DEFAULT"

  open_monitoring {
    prometheus {
      jmx_exporter {
        enabled_in_broker = false
      }
      node_exporter {
        enabled_in_broker = false
      }
    }
  }

  logging_info {
    broker_logs {
      cloudwatch_logs {
        enabled = false
      }
      firehose {
        enabled = false
      }
      s3 {
        enabled = false
      }
    }
  }

  tags = {
    Name = "example-msk-cluster"
  }
}

resource "local_file" "kafka_policy" {
  content = templatefile("${path.module}/kafka_policy_template.json", {
    cluster_arn    = aws_msk_cluster.kafka_cluster.arn,
    aws_account_id = var.account_arn
  })
  filename = "${path.module}/kafka_policy.json"
}


resource "null_resource" "kafka_cluster_policy" {
  provisioner "local-exec" {
    command = "aws kafka put-cluster-policy --cluster-arn ${aws_msk_cluster.kafka_cluster.arn} --policy file://${path.module}/kafka_policy.json"
  }
  depends_on = [local_file.kafka_policy, aws_msk_cluster.kafka_cluster]
}


resource "aws_msk_vpc_connection" "firehose_connection" {
  authentication = "SASL_IAM"
  client_subnets = [
    aws_subnet.msk_subnet_1.id,
    aws_subnet.msk_subnet_2.id
  ]
  security_groups = [
    aws_security_group.msk_sg.id
  ]
  target_cluster_arn = aws_msk_cluster.kafka_cluster.arn
  vpc_id             = aws_vpc.msk_vpc.id
}

