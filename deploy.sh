usage="--------------------------------------------------------------------------
This is the file to put it all together.

Usage:
deploy.sh [-h] [-d deployment-name]

Options:

 -h                 : display this message and exit
 -d		              : name of GCP gcloud deployment, AWS stack, and Azure resource group. This will make them all have the same name [required]
 -u                 : username that you will use to login to the VMs
 -k                 : location of the private ssh key that you will use to ssh into the various VMs
 -p                 : install the first DC and then setup the config for the other DCs?

--------------------------------------------------------------------------"
while getopts 'hd:u:k:p' opt; do
  case $opt in
    h) echo -e "$usage"
       exit 0
    ;;
    d) deploy="$OPTARG"
    ;;
    u) username="$OPTARG"
    ;;
    k) key="$OPTARG"
    ;;
    p) phased=true
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
        exit 1
    ;;
  esac
done

echo "Provisioning the VMs..."
# this kicks off the iaas piece: deploys VMs on all of the clouds and makes a list of the IP addresses
./iaas/deploy_multiple.sh -d $deploy &&

# check to see if phased install is requested, if so, then incorporate it and kickoff setup.py
echo "Installing DataStax OpsCenter and then setting up the cluster. A new browser tab will open to the installation job when it is ready. Please be patient. "
if [ "$phased" = true ] ; then
  python setup.py -u $username -s $deploy -k $key -n $deploy -p
else
  python setup.py -u $username -s $deploy -k $key -n $deploy
fi

#remove the server-list file that was created for the deployment
# rm -rf $deploy
