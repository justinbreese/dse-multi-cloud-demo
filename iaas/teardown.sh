#!/bin/bash

usage="---------------------------------------------------
Delete either CFn stack or Azure resouce group or both.

Usage:
deploy.sh [-h] [-r region] [-s stack] [-g resource-group]
-g OR -s REQUIRED
-r REQUIRED if passing -s, should be first arg

Options:

 -h                 : display this message and exit
 -r region          : AWS region where 'stack' is deployed, us-west-2 is default
 -s stack           : name of AWS CFn stack to delete
 -g resource-group  : name of Azure resource group to delete
 -d deployment-name : name of GCP gcloud deployment to delete

---------------------------------------------------"
region='us-west-2' #default region

while getopts 'hr:g:s:d:' opt; do
  case $opt in
    h) echo -e "$usage"
       exit 0
    ;;
    r) region="$OPTARG"
    ;;
    g) rg="$OPTARG"
      echo "Deleting resource group $rg, not blocking"
      az group delete -g $rg --no-wait --yes
    ;;
    s) stackname="$OPTARG"
      if [ -z "$region" ]; then
        echo -e "'region' is unset, can't continue..."
        echo -e "Rerun script with '-r region' as 1st arg"
        exit 1
      fi
      echo "Deleting CFn stack $stackname, not blocking"
      aws --region $region cloudformation delete-stack --stack-name $stackname
    ;;
    d) deploy="$OPTARG"
      echo "Deleting GCP gcloud deployment: $deploy"
      gcloud deployment-manager deployments delete $deploy -q
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
        exit 1
    ;;
  esac
done
