# handler.py for ebs-reaper
# Python 3.6
# Finds and deletes unused EBS volumes

from datetime import datetime, timedelta
import sys
import os
import boto3
from botocore.exceptions import ClientError

ENV = os.environ['env']

## Two preconditions, mutually inclusive, before deleting a volume:
# delete volume if it's been unattached for how many days
TIME_UNATTACHED = 5
# delete volume if it's older than how many days
AGE_THRESHOLD = 14

def delete_vol(client, vol_id, is_dry_run):
    try:
        response = client.delete_volume(
            VolumeId=vol_id,
            DryRun=is_dry_run
            )

        print(response)

    except ClientError as oops:
        if oops.response['Error']['Code'] == 'DryRunOperation':
            print("Dry Run!  Would have deleted %s " % vol_id)
        else:
            print(oops)
            print(str(sys.exc_info()[0]))
            raise oops

def handler(event, context):
    try:
        region = event['region']
        client_ec2 = boto3.client("ec2", region)
        client_cloudwatch = boto3.client("cloudwatch", region)

        today = datetime.now()
        start_date = today - timedelta(days=TIME_UNATTACHED)
        long_ago = today - timedelta(days=AGE_THRESHOLD)

        filters = [{'Name':'status', 'Values':['available']}]

        response = client_ec2.describe_volumes(Filters=filters)

        if ENV == 'dev':
            print("my region is ", region)
            print("response from describe volumes call:")
            print(response)
            #print("response from trying to describe ALL volumes:")
            #print(client_ec2.describe_volumes())

        for vol in response['Volumes']:
            vol_id = vol['VolumeId']
            create_date = datetime.strptime(str(vol['CreateTime']).split(" ")[0], '%Y-%m-%d')

            # if volume is not older than 'long_ago' then skip
            if create_date > long_ago:
                continue

            response = client_cloudwatch.get_metric_statistics(
                Period=3600, StartTime=start_date, EndTime=today,
                MetricName='VolumeIdleTime', Namespace='AWS/EBS', Statistics=['Average'],
                Dimensions=[{'Name': 'VolumeId', 'Value': vol_id}])

            # if there are no datapoints, then it's been unattached the whole time
            if not response['Datapoints']:
                print("Found %s created %s and avlbl >= %d days." %
                      (vol_id, vol['CreateTime'], TIME_UNATTACHED))

                if ENV == 'dev':
                    is_dry_run = True
                elif ENV == 'prod':
                    is_dry_run = False
                else:
                    is_dry_run = True

                delete_vol(client_ec2, vol_id, is_dry_run)

        return 0

    except Exception as oops:
        print(oops)
        print(str(sys.exc_info()[0]))
        raise oops
