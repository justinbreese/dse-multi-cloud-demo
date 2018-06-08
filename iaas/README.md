
# Overview
These scripts and templates deploy bare VMs (Ubuntu) in AWS, GCP, or Azure, gather their public/private ips, and tear down the deployments. The number/type of VM can be changes in the `param.json` files for each cloud.
All scripts understand `-h` and should be self documenting.

Feel free to use the key pair (`ubuntu` and `ubuntu.pub`) in this directory

## Install the CLIs for the cloud providers and jq
* Make sure that you have installed the CLIs for whichever cloud providers that you want to use. I will be using Microsoft Azure, Amazon Web Services (AWS), and Google Cloud Platform (GCP) for this example
    * Instructions on how to install the CLI for Azure: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest
    * Instructions on how to install the CLI for AWS: https://docs.aws.amazon.com/cli/latest/userguide/installing.html
    * Instructions on how to install the CLI for GCP: https://cloud.google.com/sdk/
* After you've installed the CLIs, be sure to configure each one so that you can use them.
* Install jq: `sudo apt-get install jq`

## Deploy some VMs on each cloud provider
* An example command that you can run for Azure: `./deploy_azure.sh -g jbreese-awesome`
* An example command that you can run for GCP: `./deploy_gcp.sh -d jbreese-awesome`
* An example command that you can run for AWS: `./deploy_aws.sh -s jbreese-awesome`
* Read all about the specifics below for each of the commands

## Gather the IP addresses of the clusters that you made:
* You can run the `gather_ips.sh` and the appropriate switches to get the public and private IP addresses from the deployed VMs in the given cloud providers.
* Using the above example, I created deployments in each of Azure, GCP, and AWS:
* `tee` out `./gather_ips.sh` to save everything into a nice and tidy file:
  `./gather_ips.sh -s jbreese-awesome-aws -d jbreese-awesome-azure -g jbreese-awesome-gcp | tee server-list`
* Make note of that file you just created, `server-list`, and now use that in `setup.py` from main repo directory.

## Fun facts
* the `deploy_<cloud-provider>.sh` scripts block until the resource creation completes
* `teardown.sh` does not prompt or block and places resources in a 'deleting' state immediately

## Important things to know for AWS
* The AWS deployment creates no network resources, set the `VPC`, `Subnets`, and `AvailabilityZones` parameters to those of your default VPC **in the region you are deploying to**
* The `Subnets` and `AvailabilityZones` parameters are comma separated lists of values and **must have length 3**, ie 3 subnets and 3 AZs
* The order of the `Subnets` and `AvailabilityZones` parameters **must match**, ie if `subnet-123456` is in `us-east-1a` these should be the first values in the list
* These network values can be found in the portal, or by running these commands: `aws ec2 describe-vpcs --region us-east-1` and `aws ec2 describe-subnets --region us-east-1`
* You need to create the key pair first and then reference it by name within the `params.json` file. You can do this by going to the `AWS console --> EC2 --> Network and Security --> Key Pairs`

## `deploy_aws.sh`

```
./deploy_aws.sh -h
---------------------------------------------------
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

---------------------------------------------------
```

## `deploy_azure.sh`
```
./deploy_azure.sh -h
---------------------------------------------------
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

---------------------------------------------------
```

## `deploy_gcp.sh`
```
./deploy_gcp.sh -h
---------------------------------------------------
Deploys vms in GCP based on parameters in ./gcp/clusterParameters.yaml
using Google Deployment Manager (deployment-manager).

Usage:
deploy.sh [-h] [-d deployment-name]

Options:

 -h                 : display this message and exit
 -d deployment-name : name of GCP gcloud deployment [required]

---------------------------------------------------
```

## `gather_ips.sh`
```
./gather_ips.sh -h
---------------------------------------------------
Gathers public/private ips deployed in resource group or stack,
prints to stdout 1 pair of ips per line.

Usage:
deploy.sh [-h] [-r region] [-g resource-group] [-s stack] [-d deployment-name]
-g OR -s REQUIRED
-r REQUIRED if passing -s, should be first arg

Options:

 -h                 : display this message and exit
 -r stack           : AWS region where 'stack' is deployed
 -s stack           : name of AWS CFn stack to gather node ips from
 -g resource-group  : name of Azure resource group to gather node ips from
 -d deployment-name : name of GCP gcloud deployment to gather node ips from

---------------------------------------------------
```
IPs are printed one line for each VM in the following format, `public-ip:private-ip:cloud-provider:node-number`, for AWS, Azure, and GCP
Example output:
```
./gather_ips.sh -g jbreese-awesome
52.183.115.113:10.0.0.6:Azure:0
52.151.38.28:10.0.0.5:AWS:0
52.151.34.154:10.0.0.4:GCP:0
```
Example command which will save it into a nice and tidy file:

`./gather_ips.sh -r us-east-2 -s jbreese-awesome-aws -d jbreese-awesome-azure -g jbreese-awesome-gcp | tee server-list`

Then you can use that tidy file when you run the `setup.py` script from the main directory of this repo.

## `teardown.sh`
```
./teardown.sh -h
---------------------------------------------------
Delete either AWS CFn stack, Azure resource group, GCP deployment group or all.

Usage:
teardown.sh [-h] [-r region] [-s stack] [-g resource-group] [-d deployment-name]
-g OR -s REQUIRED
-r REQUIRED if passing -s, should be first arg

Options:

 -h help            : display this message and exit
 -r region          : AWS region where 'stack' is deployed
 -s stack           : name of AWS CFn stack to delete
 -g resource-group  : name of Azure resource group to delete
 -d deployment-name : name of GCP gcloud deployment to delete

 Example:

 ./teardown.sh -r us-east-2 -s jbreese-awesome-aws -d jbreese-awesome-azure -g jbreese-awesome-gcp
```

---------------------------------------------------
