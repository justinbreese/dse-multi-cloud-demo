# Overview
These scripts and templates deploy bare VMs (Ubuntu) in AWS, GCP, or Azure, gather their public/private ips, and tear down the deployments. The number/type of VM can be changes in the `param.json` files for each cloud.

All scripts understand `-h` for help and should be self documenting.

# Install the CLIs for the cloud providers and jq
* Make sure that you have installed the CLIs for whichever cloud providers that you want to use. I will be using Microsoft Azure, Amazon Web Services (AWS), and Google Cloud Platform (GCP) for this example
    * Instructions on how to install the CLI for Azure: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest
    * Instructions on how to install the CLI for AWS: https://docs.aws.amazon.com/cli/latest/userguide/installing.html
    * Instructions on how to install the CLI for GCP: https://cloud.google.com/sdk/
* After you've installed the CLIs, be sure to configure each one so that you can use them. Important: make sure that the default output for all of the CLIs is json. You do this during configuration.
* Install jq: `brew install jq` - you will need this for the scripts to successfully parse json.

# Create a key pair that you can use for all VMs
* Use an existing one or create a new one: `ssh-keygen -C "ubuntu"`
* Choose your location to store the private and public keys
* Create that key pair to exist in AWS: EC2 --> Network & Security --> Key Pairs --> Create Key Pair
  * Update `jbreese-multicloud-ubuntu` in: ./aws/params.json` --> `"ParameterKey": "KeyName"` --> ``"ParameterValue": "jbreese-multicloud-ubuntu"` to be what you named your AWS key pair to be

# Deploy some VMs on each cloud provider and gather the IP addresses and configurations
* Make sure that you incorporate your key pair in the setup params for Azure and GCP.
* Create the key pair within the AWS console (if you're using AWS) and reference it in the AWS params file
* An example command that you can run to provision the IaaS in GCP, Azure, and AWS: `./deploy_multiple.sh -d jbreese-awesome -o some-filename`
* The `-o` flag sets the `server-list` file for use in the `setup.py` command
* Read all about the specifics below for each of the commands (e.g. change default region)

# Now go back to the main directory and setup your cluster!
* You have successfully created your infrastructure - congrats!
* Make note of that file you just created, `server-list`, and now use that in `setup.py` from the main repo directory.


## Fun facts
* the `deploy_<cloud-provider>.sh` scripts block until the resource creation completes
* `teardown.sh` does not prompt or block and places resources in a 'deleting' state immediately

## Important things to know for AWS
* The AWS deployment creates no network resources, set the `VPC`, `Subnets`, and `AvailabilityZones` parameters to those of your default VPC **in the region you are deploying to**
* The `Subnets` and `AvailabilityZones` parameters are comma separated lists of values and **must have length 3**, ie 3 subnets and 3 AZs
* The order of the `Subnets` and `AvailabilityZones` parameters **must match**, ie if `subnet-123456` is in `us-east-1a` these should be the first values in the list
* These network values can be found in the portal, or by running these commands: `aws ec2 describe-vpcs --region us-east-1` and `aws ec2 describe-subnets --region us-east-1`
* You need to create the key pair first and then reference it by name within the `params.json` file. You can do this by going to the `AWS console --> EC2 --> Network and Security --> Key Pairs`

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

 ./teardown.sh -s jbreese-awesome -d jbreese-awesome -g jbreese-awesome
```

---------------------------------------------------
