#!/bin/bash -
#
# Depends on aws-cli commands 
#
# usage : ./update_ami.sh stack-name region ami-name
# --------------------------------------------------------
# Check for stack name args
#!/bin/bash -
while getopts :a::r::s: option
do
        case "${option}" in
        a) ami=${OPTARG};;
        r) region=${OPTARG};;
        s) stack=${OPTARG};;
        esac
done
echo ${ami} ${stack} ${region}

if [[ -z ${ami} || -z ${stack} || -z ${region} ]];
then
        echo "You must specify the "
        exit 1
fi

# List all aws regions
region="us-east-1 us-west-2 us-west-1 eu-west-1 eu-central-1 ap-southeast-1 ap-northeast-1 ap-southeast-2 ap-northeast-2 sa-east-1 cn-north-1 ap-south-1"
MATCH=$2

# Check the region given in the 2nd argument is one of the valid aws regions
if echo $region | grep -w $MATCH > /dev/null; then
     echo "Using $2 as region"
else
     echo "Invalid AWS Region specified"
     exit
fi

# check aws command works
if ! [ -x "$(command -v aws)" ]; then
	echo "aws command is needed to process templates"
	exit
fi

# Remove params.json and ami.json if exists
# Delete if you have old template dumps in the folder
if [[ -f dump.json ]]; then
	rm dump.json
fi
if [[ -f params.json ]]; then
	rm paramas.json
fi

# Get parameters from running stack
aws cloudformation get-template-summary --stack-name=${stack} --output=json  --region=$2 --query  Parameters[*] > params.json
if [[ $? -ne 0 ]] ; then
    echo "AWS Command to get the template of the stack failed! Check Stack-name"
    exit
fi

# Now We are taking the dumps of the parameters, 
# 1. remove ami from the json 
# 2. convert ParameterValue to UsePreviousValue=true for all other parameters
# 3. Then adding the value for ami back and form a valid json which can be again parsed to update-stack 
list=$(cat params.json |grep 'ParameterKey'|cut -d: -f2|tr -d \"|grep -v ami)
Vpre=$(echo -e "[\n")
VList=$(for i in $list
do
        echo -e "\t{\n\t \"ParameterKey\":\"${i}\",\n\t \"UsePreviousValue\"=true \n\t },\n"
done)
VList=$(echo -e "\n ${VList} \n\t { \n\t\"ParameterKey\":\"ami\", \n\t \"ParameterValue\":\"${ami}\" } \n")
Vpost=$(echo -e "\n]")
echo -e "${Vpre} ${VList} ${Vpost}" > ami.json

# Update stack with re-written parameter json 
aws cloudformation update-stack  --region ${region} --stack-name ${stack} --use-previous-template --capabilities CAPABILITY_NAMED_IAM --parameters file://ami.json 

# Cleaning up
rm params.json
rm ami.json
 
