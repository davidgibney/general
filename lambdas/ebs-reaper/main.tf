##########################
##### Administrative #####
##########################

variable "env" {
    default = "dev"
}

### S3 backend for tfstate ###
terraform {
	backend "s3" {
		bucket  = "my-awesome-devops-bucket"
		key     = "terraform/tf-ebs-reaper/terraform.tfstate"
		region  = "us-west-2"
		encrypt = "true"
		profile = "default"
	}
}

### Provider ###
provider "aws" {
	access_key = "${var.aws_access_key}"
	secret_key = "${var.aws_secret_key}"
	region 	   = "us-west-2"
}
