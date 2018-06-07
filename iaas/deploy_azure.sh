#!/bin/bash

rg='multi'
loc="westus"
usage="---------------------------------------------------
Deploys vms based on params in ./azure/params.json to
a resource group.

Usage:
deploy.sh [-h] [-l region] [-g resource-group]

Options:

 -h                 : display this message and exit
 -l region          : Azure region where 'resource-group' will be deployed,
                      default westus2
 -g resource-group  : name of resource-group to deploy,
                      default 'multi'

---------------------------------------------------"

while getopts 'hl:g:' opt; do
  case $opt in
    h) echo -e "$usage"
       exit 0
    ;;
    l) loc="$OPTARG"
    ;;
    g) rg="$OPTARG"
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
        exit 1
    ;;
  esac
done

rand=$(LC_ALL=C tr -cd '[:alnum:]' < /dev/urandom | tr -cd '[:lower:]' | fold -w10 | head -n1)

az group create --name $rg --location $loc
az group deployment create \
--resource-group $rg \
--template-file ./azure/template-vnet.json \
--verbose

az group deployment create \
--resource-group $rg \
--template-file ./azure/nodes.json \
--parameters @./azure/params.json \
--parameters '{"uniqueString": {"value": "'$rand'"}}' \
--verbose