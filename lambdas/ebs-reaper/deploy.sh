#!/bin/sh
# expects a zip archive to already exist, ebs_remover.zip

echo "deploy to dev or prod?  Without quotes, enter \"dev\" or \"prod\" now: "
read env

terraform workspace select $env

zip -g ebs_remover.zip handler.py

if [ "$env" == "prod" ]; then
    terraform apply -var 'env=prod'
else
    # default env var is to dev
    terraform apply
fi