#!/bin/bash

region='us-east-1'
stackname='multi'
usage="---------------------------------------------------
Deploys vms based on params in ./aws/params.json
in a CFn stack.

Usage:
deploy.sh [-h] [-r region] [-s stack]

Options:

 -h                 : display this message and exit
 -r region          : AWS region where 'stack' will be deployed,
                      default us-east-1
 -s stack           : name of AWS CFn stack to deploy,
                      default 'multi'

---------------------------------------------------"

while getopts 'hr:s:' opt; do
  case $opt in
    h) echo -e "$usage"
       exit 0
    ;;
    r) region="$OPTARG"
    ;;
    s) stackname="$OPTARG"
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
        exit 1
    ;;
  esac
done

echo "Deploying 'datacenter.template' in stack $stackname in region $region"
aws cloudformation create-stack  \
--region $region \
--stack-name $stackname  \
--disable-rollback  \
--capabilities CAPABILITY_IAM  \
--template-body file://$(pwd)/aws/datacenter.template  \
--parameters file://$(pwd)/aws/params.json
echo "Waiting for stack to complete..."
sleep 30s #avoid fail?
aws cloudformation wait stack-create-complete --stack-name $stackname
