################################
##### EBS Reaper - Lambda #####
################################

### Lambda function ###
resource "aws_lambda_function" "ebs_reaper_lambda" {
  filename         = "ebs_reaper.zip"
  function_name    = "ebs_reaper__${var.env}"
  role             = "${aws_iam_role.ebs_reaper_role.arn}"
  handler          = "handler.handler"
  source_code_hash = "${base64sha256(file("ebs_reaper.zip"))}"
  runtime          = "python3.6"
  timeout          = 90
  description      = "Custom script to clean up unused EBS volumes"

  environment {
    variables = {
      env = "${var.env}"
    }
  }

  tags {
    env                   = "${var.env}"
    owner                 = "dgibney"
    project               = "devops-other-ebs"
    managed_by_terraform  = "true - check devops repo"
  }

}



### IAM Role for Lambda function ###
resource "aws_iam_role" "ebs_reaper_role" {
  name = "ebs_reaper__${var.env}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Action": "sts:AssumeRole",
        "Principal": {
            "Service": "lambda.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": "AssumeRoleForLambda"
    }
  ]
}
EOF
}


### IAM Policy to attach to the Lambda's role ###
resource "aws_iam_policy" "ebs_reaper_policy" {
  name   = "ebs_reaper_policy__${var.env}"
  path   = "/"
  policy = "${file("lambda-role-policy.json")}"
}

### Attach the policy to the role ###
resource "aws_iam_role_policy_attachment" "attach_ebs_reaper_policy" {
    role       = "${aws_iam_role.ebs_reaper_role.name}"
    policy_arn = "${aws_iam_policy.ebs_reaper_policy.arn}"
}
