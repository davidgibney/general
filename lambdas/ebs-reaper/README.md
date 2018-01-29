ebs-reaper
--------------

Terraform and python code that presents a service that automatically checks for and deletes unattached EBS volumes.

This service will delete volumes that are older than 14 days and that have been unattached for more than 5 days.


Deployment
----------

Create two terraform workspaces named 'dev' and 'prod'.  Then,

Run the deploy.sh script
