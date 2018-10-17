#!/bin/bash

region='us-west-2'
stackname='multi'
usage="---------------------------------------------------
Deploys vms based on params in ./aws/params.json
in a CFn stack.

Usage:
deploy.sh [-h] [-r region] [-s stack]

Options:

 -h                 : display this message and exit
 -r region          : AWS region where 'stack' will be deployed,
                      default us-west-2
 -s stack           : name of AWS CFn stack to deploy,
                      default 'multi'
 -a                 : automated install
---------------------------------------------------"

while getopts 'hr:s:a' opt; do
  case $opt in
    h) echo -e "$usage"
       exit 0
    ;;
    r) region="$OPTARG"
    ;;
    s) stackname="$OPTARG"
    ;;
    a) automated=true
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
--template-body file://$(pwd)/iaas/aws/datacenter.template  \
--parameters file://$(pwd)/iaas/aws/params.json
echo "Waiting for stack to complete..."
sleep 30s #avoid fail?
aws cloudformation wait stack-create-complete --stack-name $stackname

# gather the IP addresses and store them in the main directory file
# check to see if you are doing the automated process versus the manual process
if [ "$automated" = true ] ; then
  ./iaas/gather_ips.sh -a -s $stackname ->> $stackname
else
  ./iaas/gather_ips.sh -s $stackname ->> $stackname
fi
