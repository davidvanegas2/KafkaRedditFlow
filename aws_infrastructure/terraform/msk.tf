resource "aws_msk_cluster" "example" {
  cluster_name = "example-msk-cluster"

  kafka_version          = "3.5.1"
  number_of_broker_nodes = 2 # Minimizing broker nodes to reduce cost.

  broker_node_group_info {
    instance_type = "kafka.t3.small" # Choose the smallest instance type available

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
      }
    }
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
