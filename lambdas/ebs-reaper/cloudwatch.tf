#####################################################
#### Terraform to manage resources in CloudWatch ####
#####################################################

resource "aws_cloudwatch_log_group" "loggroup" {
 name = "/aws/lambda/ebs_remover__${var.env}"
}
