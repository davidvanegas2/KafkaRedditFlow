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

# resource "aws_msk_cluster_policy" "kafka_cluster_policy" {
#   cluster_arn = aws_msk_cluster.kafka_cluster.arn
#
#   policy = jsonencode(
#     {
#       Version = "2012-10-17",
#       Statement = [
#         {
#           Effect = "Allow",
#           Principal = {
#             AWS = "arn:aws:iam::719386081370:root"
#           },
#           Action = [
#             "kafka:CreateVpcConnection",
#             "kafka:GetBootstrapBrokers",
#             "kafka:DescribeCluster",
#             "kafka:DescribeClusterV2"
#           ],
#           Resource = aws_msk_cluster.kafka_cluster.arn
#         },
#         {
#           Effect = "Allow",
#           Principal = {
#             Service = "firehose.amazonaws.com"
#           },
#           Action = [
#             "kafka:CreateVpcConnection",
#             "kafka:GetBootstrapBrokers",
#             "kafka:DescribeCluster",
#             "kafka:DescribeClusterV2"
#           ],
#           Resource = aws_msk_cluster.kafka_cluster.arn
#         }
#       ]
#     }
#   )
# }

resource "local_file" "kafka_policy" {
  content = templatefile("${path.module}/kafka_policy_template.json", {
    cluster_arn    = aws_msk_cluster.kafka_cluster.arn,
    aws_account_id = var.account_arn
  })
  filename = "${path.module}/kafka_policy.json"
}


resource "null_resource" "kafka_cluster_policy" {
  provisioner "local-exec" {
    command = <<EOT
      aws kafka put-cluster-policy \
        --cluster-arn ${aws_msk_cluster.kafka_cluster.arn} \
        --current-version $(aws kafka get-cluster-policy --cluster-arn arn:aws:kafka:us-west-2:719386081370:cluster/example-msk-cluster/c61a0784-116d-40fd-8dc2-07498fcc32c4-7 | jq -r '.CurrentVersion') \
        --policy file://kafka_policy.json
    EOT
  }
  depends_on = [local_file.kafka_policy, aws_msk_cluster.kafka_cluster]
}
