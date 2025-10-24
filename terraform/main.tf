resource "aws_s3_bucket" "raw_dataset" {
  bucket = var.raw_dataset
  tags = {
    Name        = var.raw_dataset
    Environment = "Dev"
  }
}

resource "aws_s3_bucket" "processed_dataset" {
  bucket = var.processed_dataset
  tags = {
    Name        = var.processed_dataset
    Environment = "Dev"
  }
}

resource "aws_s3_bucket" "trained_models" {
  bucket = var.trained_models
  tags = {
    Name        = var.trained_models
    Environment = "Dev"
  }
}