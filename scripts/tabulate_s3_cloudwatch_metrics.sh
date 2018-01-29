#!/bin/bash

# Use this script to get cloudwatch metrics for your s3 buckets.
# It outputs a summary to stdout, and outputs a detailed table to
# a file in your /tmp/ directory.

## Assumptions of this script:
# you will run this script on debian or redhat flavor of linux
# you have ran `aws configure`
# you have the program 'jq' installed
# your aws access key has IAM permissions to cloudwatch

yesterday=`date --date="1 day ago" +%Y-%m-%d`
today=`date +%Y-%m-%d`
local_report_file_destination=/tmp/s3-buckets-cloudwatch-report-$today.csv

# get listing of buckets
aws s3 ls | awk '{print $3}' > /tmp/list-of-s3-buckets.txt

# make header row for csv
echo "bucket,number_of_objects,tb_in_ia,tb_in_standard,bytes_in_ia,bytes_in_standard" > $local_report_file_destination

# function to get metrics
fn_get_metrics () {
  # three args to be passed:
  # metric name, bucket name, storage type

  aws cloudwatch get-metric-statistics --namespace "AWS/S3" --metric-name $1 --statistics Average \
    --start-time $yesterday --end-time $today --period 3600 \
    --dimensions Name=BucketName,Value=$2 Name=StorageType,Value=$3 | jq '.Datapoints[0].Average'

}

# now let's get all the metrics for all the buckets
for bucket in `cat /tmp/list-of-s3-buckets.txt`; do

  number_of_objects=`fn_get_metrics "NumberOfObjects" $bucket "AllStorageTypes"`
  bytes_in_ia=`fn_get_metrics "BucketSizeBytes" $bucket "StandardIAStorage"`
  bytes_in_standard=`fn_get_metrics "BucketSizeBytes" $bucket "StandardStorage"`

  if [ "$number_of_objects" == "null" ]; then
    number_of_objects=0
  fi

  if [ "$bytes_in_ia" == "null" ]; then
    bytes_in_ia=0
    tb_in_ia=`echo $(($bytes_in_ia / 1099511627776))`
  else
    tb_in_ia=`echo $(($bytes_in_ia / 1099511627776))`
  fi

  if [ "$bytes_in_standard" == "null" ]; then
    bytes_in_standard=0
    tb_in_standard=`echo $(($bytes_in_standard / 1099511627776))`
  else
    tb_in_standard=`echo $(($bytes_in_standard / 1099511627776))`
  fi


  echo "$bucket,$number_of_objects,$tb_in_ia,$tb_in_standard,$bytes_in_ia,$bytes_in_standard" >> $local_report_file_destination

done


echo "Total TB in IA:"
echo `tail -n +2 $local_report_file_destination | awk -F "," '{print $3}' | awk '{ sum += $1 } END { print sum }'`
echo "Total TB in Standard:"
echo `tail -n +2 $local_report_file_destination | awk -F "," '{print $4}' | awk '{ sum += $1 } END { print sum }'`
echo "Total number of objects:"
echo `tail -n +2 $local_report_file_destination | awk -F "," '{print $2}' | awk '{ sum += $1 } END { print sum }'`

echo -e "\nRemember to see $local_report_file_destination for a full report of the S3 buckets."
