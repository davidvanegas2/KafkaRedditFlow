resource "aws_glue_catalog_database" "lakehouse_db" {
  name = "lakehouse_db"
}

resource "aws_glue_catalog_table" "reddit_posts" {
  database_name = aws_glue_catalog_database.lakehouse_db.name
  name          = "reddit_posts"
  parameters = {
    format = "parquet"
  }

  table_type = "EXTERNAL_TABLE"

  open_table_format_input {
    iceberg_input {
      metadata_operation = "CREATE"
      version            = "2"
    }
  }

  storage_descriptor {
    location = "s3://${aws_s3_bucket.firehose_bucket.bucket}/reddit_posts"

    columns {
      name = "id"
      type = "string"
    }

    columns {
      name = "title"
      type = "string"
    }

    columns {
      name = "author"
      type = "string"
    }

    columns {
      name = "subreddit"
      type = "string"
    }

    columns {
      name = "year"
      type = "int"
    }

    columns {
      name = "month"
      type = "int"
    }

    columns {
      name = "day"
      type = "int"
    }

    columns {
      name = "url"
      type = "string"
    }

    columns {
      name = "score"
      type = "int"
    }

    columns {
      name = "num_comments"
      type = "int"
    }

  }
}
