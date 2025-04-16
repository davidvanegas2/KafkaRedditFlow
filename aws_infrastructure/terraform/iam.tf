# ------------------------------ MSK ROLE ------------------------------



# ------------------------------ FIREHOSE ROLE ------------------------------

data "aws_iam_policy_document" "firehose_policy_document" {
  statement {
    effect = "Allow"

    principals {
      identifiers = ["firehose.amazonaws.com"]
      type        = "Service"
    }

    actions = [
      "sts:AssumeRole"
    ]
  }
}

resource "aws_iam_role" "firehose_msk_role" {
  name = "firehose-msk-role"

  assume_role_policy = data.aws_iam_policy_document.firehose_policy_document.json
}

resource "aws_iam_policy" "firehose_msk_policy" {
  name = "firehose-msk-policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "*"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "firehose_msk_policy_attachment" {
  role       = aws_iam_role.firehose_msk_role.name
  policy_arn = aws_iam_policy.firehose_msk_policy.arn
}

# ------------------------------ EC2 ROLE ------------------------------
resource "aws_iam_role" "ec2_kafka_producer_role" {
  name = "ec2-kafka-producer-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "ec2_kafka_msk_policy" {
  name = "ec2-msk-policy"
  role = aws_iam_role.ec2_kafka_producer_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        "Effect" : "Allow",
        "Action" : [
          "kafka-cluster:*"
        ],
        "Resource" : "*"
      },
      {
        Effect = "Allow",
        Action = [
          "logs:*",
          "cloudwatch:*",
          "ec2:Describe*"
        ],
        Resource = "*"
      }
    ]
  })
}

