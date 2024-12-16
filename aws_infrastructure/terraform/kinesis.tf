resource "aws_kinesis_firehose_delivery_stream" "reddit_posts_stream" {
  name        = "msk-to-iceberg"
  destination = "iceberg"

  msk_source_configuration {
    msk_cluster_arn = aws_msk_cluster.kafka_cluster.arn
    topic_name      = "reddit_posts"
    authentication_configuration {
      connectivity = "PRIVATE"
      role_arn     = aws_iam_role.firehose_msk_role.arn
    }
  }

  iceberg_configuration {
    catalog_arn = "arn:${data.aws_partition.current.partition}:glue:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:catalog"
    role_arn    = aws_iam_role.firehose_msk_role.arn

    s3_configuration {
      bucket_arn = aws_s3_bucket.firehose_bucket.arn
      role_arn   = aws_iam_role.firehose_msk_role.arn

      prefix              = "reddit_posts/"
      error_output_prefix = "reddit_posts_error/!{firehose:error-output-type}/"
    }

    destination_table_configuration {
      database_name = aws_glue_catalog_database.lakehouse_db.name
      table_name    = aws_glue_catalog_table.reddit_posts.name
    }
  }

}
