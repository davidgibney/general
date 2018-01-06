Making lambdas
------------------------


I had the project of making a custom monitoring and alerting tool for an internal web page.  The requirement was that we needed a custom script that could connect to the MS SQL DB that the web page uses, and periodically check on the data integrity in this DB.

Enter Lambda!  Having one small lambda run every 5 minutes is cheaper than hosting the script on an EC2 instance.  Plus, it's easy to connect other AWS services up to a Lambda, to either alert on its output or just log it or whatever.

To make a Lambda function, it is recommended to dev and test it on an EC2 instance running Amazon Linux.  This is because the AWS Lambda functions are run on docker containers running Amazon Linux (bet ya didn't know that (wink)).



This particular project is a good example, because it covers what to do if you have shared libraries that need compiled (rare, but it happens - and it's extra steps).



So on the t2.micro running Amazon Linux, this is what I had to do just to set up the environment and build the lambda package...:



# Setup env and dependencies for lambda function

``` bash
# install dependencies
yum -y update
yum -y install epel-release
yum -y install yum-utils
yum -y install gcc zlib zlib-devel openssl openssl-devel
yum -y groupinstall development
yum -y install gcc-c++
yum -y install https://centos6.iuscommunity.org/ius-release.rpm
yum -y install python36u
yum -y install python36u-pip
yum -y install python36u-devel
yum -y install unixODBC unixODBC-devel
wget https://gallery.technet.microsoft.com/ODBC-Driver-13-for-SQL-8d067754/file/153653/4/install.sh
sh install.sh
 
# virtual env
mkdir /venvs
cd /venvs
pip3.6 install virtualenv
python3.6 -m venv my_project
cd my_project
source bin/activate
 
# install pymssql package
pip3 install pymssql
 
# had to copy over some system drivers
cp /opt/microsoft/msodbcsql/lib64/libmsodbcsql-13.1.so.9.1 /venvs/my_project/
cp /usr/lib64/libsybdb.so.5 /venvs/my_project/
 
 
### had to build shared libraries from source!
 
wget ftp://ftp.freetds.org/pub/freetds/stable/freetds-patched.tar.gz ./
gunzip freetds-patched.tar.gz
tar xvf freetds-patched.tar.gz
cd freetds-1.00.80/
./configure --prefix=/venvs/my_project/
make
make install
 
wget http://www.unixodbc.org/unixODBC-2.3.5.tar.gz ./
gunzip unixODBC-2.3.5.tar.gz
tar xvf unixODBC-2.3.5.tar
cd unixODBC-2.3.5
./configure --prefix=/venvs/my_project/
make
make install
 
 
# put your handler.py in the root dir of the venv
# and copy everything under lib/ and site-packages/ into the root dir of the venv
# rm the tarballs and lib folder to save space
# zip it up and you've got your lambda package
zip -r9 my_project.zip .
```


You can see that I wanted to use the Python 3 runtime environment for my Lambda function, and I needed to use the library 'pymssql' so that I can connect to the MS SQL DB.  This pymssql library has a couple dependencies:  FreeTDS, unixODBC, and Microsoft's ODBC driver.

To get your zip file you can scp it down from your workstation, or, if you have the IAM permissions attached to the instance, you can upload it to S3 from the ec2 instance, or create/update the lambda function with the AWS CLI, from the instance.



Because this lambda function aims to access a resource (ec2 instance) in the private VPC, you just need to make sure that the role(s) attached to the lambda function allow that permission.  Also, you must ensure that the correct subnets and security groups are attached to the lambda.  A suggestion for testing and troubleshooting connection issues between your lambda and ec2 instance is to have a function in your lambda that pings the server, .e.g....

``` python
def host_is_up(server):
    response = os.system("ping -c 1 " + server)
    if response == 0: 
        return true
    else:
        return false
```





For any other gotchas when dealing with Lambda, this blog post provides some good tips:   

[iheavy.com](http://www.iheavy.com/2016/02/14/getting-errors-building-amazon-lambda-python-functions-help-howto/)


