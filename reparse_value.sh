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
if [[ $# -eq 0 ]] ; then
    echo 'Requires stack-name'
    exit 0
fi

# Check for change.properties file
if [[ ! -f change.properties ]] ; then
    echo 'File "change.properties" is not there, aborting.'
    exit
fi

# make sure that aws is configured and useable
if [[ ! -f ~/.aws/config ]] ; then
    echo 'File "/.aws/config" is not there, Run "aws configure" first.'
    exit
fi

# check if jq works
if ! [ -x "$(command -v jq)" ]; then
	echo "jq command is needed to parse jsons"
	exit
fi

# check aws command works
if ! [ -x "$(command -v aws)" ]; then
	echo "aws command is needed to process templates"
	exit
fi

# Delete if you have old template dumps in the folder
if [[ -f dump.json ]]; then
	rm dump.json
fi

# create new dump of the running template of the stack
aws cloudformation get_stack --stack-name=$1 --output=json > dump.json

# Get the parameters seperated ... 
jq -c '.TemplateBody.Parameters' dump.json > params.json

# Logic to change and merge parameters into the original stack is still on
# jq '(.[] | select(.default == "*") | .format) |= "csv"' params.json

# Now replace the old parameters with new parameters merging parameters given in the change.properties file
#

# Update stack with new template to running template
# aws cloudformation update-stack --stack-name $1 --template-body file:///dump.json --capabilities CAPABILITY_NAMED_IAM --parameters $(cat change.properties)
