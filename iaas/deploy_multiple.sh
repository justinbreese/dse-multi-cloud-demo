usage="--------------------------------------------------------------------------
Deploys VMs in GCP, AWS, and Azure based on parameters in ./gcp/clusterParameters.yaml, ./azure/params.json, and ./aws/params.json
using their respective CLIs.

Usage:
deploy.sh [-h] [-d deployment-name]

Options:

 -h                 : display this message and exit
 -d		              : name of GCP gcloud deployment, AWS stack, and Azure resource group. This will make them all have the same name [required]
 -o                 : name of the output file [required]

--------------------------------------------------------------------------"

while getopts ':h:d:o:' opt; do
  case $opt in
    h) echo -e "$usage"
       exit 0
    ;;
    d) deploy="$OPTARG"
    ;;
    o) output="$OPTARG"
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
        exit 1
    ;;
  esac
done

echo "Deleting contents of your server-list file..."
# looking to see if the server-list file exists and deleting the contents if it does
[ -f $output ] && > $output
echo "Deploying GCP..."
./deploy_gcp.sh -d $deploy -o $output &
echo "Deploying AWS..."
./deploy_aws.sh -s $deploy -o $output &
echo "Deploying Azure..."
./deploy_azure.sh -g $deploy -o $output &
