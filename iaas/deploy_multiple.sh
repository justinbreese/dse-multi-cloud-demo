region='us-west-2'
stackname='multi'
rg='multi'
loc="westus"

usage="--------------------------------------------------------------------------
Deploys VMs in GCP, AWS, and Azure based on parameters in ./gcp/clusterParameters.yaml, ./azure/params.json, and ./aws/params.json
using their respective CLIs.

Usage:
deploy.sh [-h] [-d deployment-name]

Options:

 -h                 : display this message and exit
 -d		              : name of GCP gcloud deployment, AWS stack, and Azure resource group. This will make them all have the same name [required]

--------------------------------------------------------------------------"
while getopts 'hd:' opt; do
  case $opt in
    h) echo -e "$usage"
       exit 0
    ;;
    d) deploy="$OPTARG"
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
        exit 1
    ;;
  esac
done

# looking to see if the server-list file exists and deleting the contents if it does
[ -f $deploy ] && > $deploy

# GCP Section
./iaas/deploy_gcp.sh -d $deploy &

# AWS Section
./iaas/deploy_aws.sh -s $deploy -a &

# Azure Section
# not using the & because Azure is the slowest to provision, when this command is done, it will kick off the setup.py script in deploy.sh
./iaas/deploy_azure.sh -g $deploy
