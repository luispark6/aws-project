variable "aws_region" {
  description = "AWS region to deploy resources"
  default     = "us-east-1"
}

variable "raw_dataset" {
  description = "Name of the S3 bucket"
  default     = "dataset-lpark-raw"
}

variable "processed_dataset" {
  description = "Name of the S3 bucket"
  default     = "dataset-lpark-processed"
}

variable "trained_models" {
  description = "Name of the S3 bucket"
  default     = "models-lpark"
}