variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "prefix" {
  default = "my"
}

variable "ami_id" {
  default = "ami-0f403e3180720dd7e"
}