output "bootstrap_brokers" {
  value = aws_msk_cluster.kafka_cluster.bootstrap_brokers
}

output "zookeeper_connect_string" {
  value = aws_msk_cluster.kafka_cluster.zookeeper_connect_string
}
