resource "aws_s3_bucket" "firehose_bucket" {
  bucket        = "msk-to-iceberg-data"
  force_destroy = true

  tags = {
    Name = "lakehouse_bucket"
  }
}
