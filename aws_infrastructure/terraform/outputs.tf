output "bootstrap_brokers" {
  value = aws_msk_cluster.example.bootstrap_brokers
}

output "zookeeper_connect_string" {
  value = aws_msk_cluster.example.zookeeper_connect_string
}
