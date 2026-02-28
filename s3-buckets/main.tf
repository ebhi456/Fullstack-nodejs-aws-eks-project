provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "bucket1" {
  bucket = "ebi-booksec2"
  # Allow Terraform destroy to remove the bucket even when it contains objects/versions.
  force_destroy = true

  tags = {
    Name        = "ebi-booksec2"
    Environment = "dev"
  }
}

resource "aws_s3_bucket_versioning" "bucket1_versioning" {
  bucket = aws_s3_bucket.bucket1.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket" "bucket2" {
  bucket = "new-bookseks"
  # Allow Terraform destroy to remove the bucket even when it contains objects/versions.
  force_destroy = true

  tags = {
    Name        = "new-bookseks"
    Environment = "dev"
  }
}

resource "aws_s3_bucket_versioning" "bucket2_versioning" {
  bucket = aws_s3_bucket.bucket2.id
  versioning_configuration {
    status = "Enabled"
  }
}
