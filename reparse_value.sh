#!/bin/bash -
# This script loads parameter changes from file change.properties
# and pulls the cloudformation template from the running stack.
# Merges changes from change.properties to the dumped cf template
# Updates the running template with changed parameters
#
# Used aws-cli and jq
#
# usage : ./reparse_value.sh <stack-name>
# --------------------------------------------------------
# Check for stack name args
if [ $# -ne 2 ]; then
    echo './reparse_value.sh stack-name region-name'
    exit 0
fi

region="us-east-1 us-west-2 us-west-1 eu-west-1 eu-central-1 ap-southeast-1 ap-northeast-1 ap-southeast-2 ap-northeast-2 sa-east-1 cn-north-1 ap-south-1"
MATCH=$2

if echo $region | grep -w $MATCH > /dev/null; then
     echo "Using $2 as region"
else
     echo "Invalid AWS Region specified"
     exit
fi


# Check for change.properties file
if [[ ! -f change.properties ]] ; then
    echo 'File "change.properties" is not there, aborting.'
    exit
fi

# check aws command works
if ! [ -x "$(command -v aws)" ]; then
	echo "aws command is needed to process templates"
	exit
fi

# Delete if you have old template dumps in the folder
if [[ -f params.json ]]; then
	rm paramas.json
fi

# create new dump of the running template of the stack
aws cloudformation get-template-summary --stack-name $1 --output=json  --region=$2 > dump.json
aws cloudformation get-template-summary --stack-name=$1 --output=json  --region=$2 --query  Parameters[*] > params.json
../jsoncsv.sh
# aws cloudformation update-stack --stack-name $1  --region=$2 --template-body file:///dump.json --capabilities CAPABILITY_NAMED_IAM --parameters $(cat change.properties)
