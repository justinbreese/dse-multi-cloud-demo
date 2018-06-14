#!/bin/bash

usage="---------------------------------------------------
Gathers public/private ips deployed in resource group or stack,
prints to stdout 1 pair of ips per line.

Usage:
deploy.sh [-h] [-r region] [-g resource-group] [-s stack] [-d deployment-name]
-g OR -s REQUIRED
-r REQUIRED if passing -s, should be first arg

Options:

 -h                  : display this message and exit
 -r region           : AWS region where 'stack' is deployed, us-west-2 is default
 -s stack            : name of AWS CFn stack to gather node ips from
 -g resource-group   : name of Azure resource group to gather node ips from
 -d deployment-name  : name of GCP gcloud deployment to gather node ips from

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
      json=$(az group deployment show -g $rg -n nodes)

      namespace=$(echo $json | jq ' .properties.parameters.namespace.value ' | tr -d '"')
      num=$(echo $json | jq ' .properties.parameters.nodeCount.value ' | tr -d '"')
      for i in `seq 0 $((num-1))`;
      do
        vm=$namespace'vm'$i
        pubip=$(az vm show -g $rg -n $vm -d --query publicIps | tr -d '"')
        privip=$(az vm show -g $rg -n $vm -d --query privateIps | tr -d '"')
        echo $pubip':'$privip':Azure:'$i
      done
      #exit 0
    ;;
    s) stackname="$OPTARG"
      if [ -z "$region" ]; then
        echo -e "'region' is unset, can't continue..."
        echo -e "Rerun script with '-r region' as 1st arg"
        exit 1
      fi
      physid=$(aws --region $region cloudformation describe-stack-resources --stack-name $stackname | \
       jq '.StackResources[] | select(.ResourceType=="AWS::AutoScaling::AutoScalingGroup") | .PhysicalResourceId' | tr -d '"')

      instances=$(aws --region $region autoscaling describe-auto-scaling-groups --auto-scaling-group-names $physid | \
       jq ' .AutoScalingGroups[0] | .Instances[].InstanceId ' | tr "\n" " " | tr -d '"')
       cnt=0
       for i in $instances; do
         pubip=$(aws --region $region ec2 describe-instances --instance-ids $i | jq ' .Reservations[].Instances[].PublicIpAddress ' | tr -d '"')
         privip=$(aws --region $region ec2 describe-instances --instance-ids $i | jq ' .Reservations[].Instances[].PrivateIpAddress ' | tr -d '"')
         echo $pubip':'$privip':AWS:'$cnt
         cnt=$((cnt+1))
       done
       #exit 0
    ;;
    d) deploy="$OPTARG"
       #echo Google Compute Engine [deployment: $deploy]
       gcloud compute instances list --filter="tags.items=($deploy)" | tail -n +2 | awk '{print $5 ":" $4":GCP:"NR-1}'
       #exit 0
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
        exit 1
    ;;
  esac
done

#echo "No options passed, exiting"
#exit 1
