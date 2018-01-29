#!/bin/bash

# blame david gibney
# Firewall verify 
# Takes a file as input, a list of IPs to test connection against.
# The file can have 3 different formats, and this is documented in the help function.


## Global vars
filepath=""
ports=""
fileformat=0
RED='\033[0;31m'
NC='\033[0m' # No Color

help() {
    cat <<EOF
    ABOUT:
    This script is meant to verify access to endpoints, say after requesting firewall changes.
    Fire it off from a host in each subnet that you need to verify can access the endpoints in your list.
    Requires nmap.
    
    USAGE: $0 [options]
    
    -h| --help                               Display help information.
    -f| --file <path_to_file>                Specify path to file, a list of IPs to test.
    -p| --ports <num1[,num2,num3...]>        Specify port(s) to test with each IP, comma-delimited.
    
    Example:
    ./firewall-verify.sh -f /tmp/ip-source-list.txt -p 443 8443
    
    NOTE:
    To make it easier, the source file can have the list of endpoints in different formats:

    1) 10.72.7.184 PORT 443
       10.72.7.185 PORT 443,8443
       etc
    2) 10.72.7.184:443
       10.72.7.185:443,8443
       etc
    3) 10.72.7.184
       10.72.7.185
       etc (and the user can manually specify the port(s) when calling the script)
       
    If you use options 1 or 2, then you should NOT manually specify the port(s) with the -p parameter flag.
    Options 1 and 2 are convenient if you want a mix of some IPs with certain ports, and some IPs with other certain ports.
    Your file must have consistent format throughout the file. E.g., the first half of the file cannot be of format type 1,
    and second half be of format type 2.
    
    Your IPs can also be specified with CIDR notation; some examples:
    10.72.7.0/24 PORT 443
    10.72.7.0/24:443
    10.72.7.0/24
EOF
exit 1
}

if [ $# -eq 0 ]
then
    help
fi

findfileformat() {
    # Determine list format from the file
    head -1 $filepath | grep "PORT" > /dev/null
    if [ $? -eq 0 ]
    then
        fileformat=1
    fi
    head -1 $filepath | grep ":" > /dev/null
    if [ $? -eq 0 ]
    then
        fileformat=2
    fi
    head -1 $filepath | egrep "PORT|:" > /dev/null
    if [ $? -eq 1 ]
    then
        fileformat=3
    fi
}


while test $# -gt 0
do
    case "$1" in
    -h)
        help
        ;;
    --help)
        help
        ;;
    -f)
        filepath="$2"
        findfileformat
        ;;
    --file)
        filepath="$2"
        findfileformat
        ;;
    -p)
        while test $# -gt 0
        do
            ports+="$2 "
            shift
        done
        ;;
    --ports)
        while test $# -gt 0
        do
            ports+="$2 "
            shift
        done
        ;;
    *)
        echo ""
        ;;
    esac
    shift
done


testendpoint() {
    # Use nmap to check the endpoint!
    # First arg is the port or comma-separated list of ports, second arg is the IP
    /usr/bin/nmap -p $1 $2 -Pn | egrep "closed|filtered|down"
    
    if [ $? -eq 0 ]; then
        thehostname=`host $2 | awk '{print $5}'`
        echo -e "$2 $thehostname\n\n"
    fi
    
}



##############
#### MAIN ####
##############

## Make sure nmap is installed
if ! which nmap > /dev/null; then
    /usr/bin/yum install -y nmap > /dev/null
    
    if [ $? -ne 0 ]
    then
        echo "Could not install nmap, exiting..."
        exit 1
    fi
fi

echo -e "\nMy network adapter(s) config information:"
/sbin/ifconfig | grep "Mask" | grep -v "127.0.0.1"

echo -e "\nnmap legend: closed - endpoint isn't listening; filtered - firewall is blocking; down - no route to host, no ICMP, or host is down.\n\n"

## Now go through each line of the specified file
while read line
do
    ## File format 1
    if [ $fileformat -eq 1 ]
    then
        theip=`echo $line | awk '{print $1}'`
        theports=`echo $line | awk '{print $3}'`
        testendpoint $theports $theip
        
    fi
    
    ## File format 2
    if [ $fileformat -eq 2 ]
    then
        theip=`echo $line | awk -F ":" '{print $1}'`
        theports=`echo $line | awk -F ":" '{print $2}'`

        testendpoint $theports $theip
    fi
    
    ## File format 3
    if [ $fileformat -eq 3 ]
    then
        
        if [ "$ports" == "" ]
        then
            echo "You are using the file format of #3, just IPs, but you did not manually specify any ports! Exiting..."
            exit 1
        fi
        
        theip=`echo $line`
        theports="$ports"

        testendpoint $theports $theip
    fi
    
done < $filepath



exit 0

