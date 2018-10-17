# dse-multi-cloud-demo
What if I told you that you could have your data layer could be completely secured and span across several public cloud providers and on-premises (hybrid) at the same time? With DataStax we make it really easy to be on-prem, in the cloud, hybrid, or even multi-cloud.

Multi-cloud is starting to be very important for customers. By leveraging multiple public clouds, they're able to maintain data portability as well as being able to shop around to find the best infrastructure price for their given workloads. DataStax Enterprise provides that level of portability that they would not have by just using one public cloud.

You also have the ability to manage and develop on this multi/hybrid cloud through one single pane of glass with DataStax OpsCenter and DataStax Studio.

Yes, it is possible. And yes, you can do it!

# The basics
# Set these environmental variables in your .bash_profile:
```
export cassandra_default_password="blah"
export academy_user="blah"
export academy_pass="blah"
export academy_token="blah"
```
Be sure to replace `blah` with your credentials. If you don't have credentials for DataStax Academy, then go and sign up for it at http://academy.datastax.com - it's free!  Be sure to create a download key (token) for your downloads too.

# The more manual way
If you are a masochist and want to do more of a manual method of provisioning VMs, gathering IP addresses, and running the setup then check out `MANUAL-METHOD.md` for more instructions

# The easy way
This is how you can get it up and running within a matter of minutes - completely automated

# Install the CLIs for the cloud providers and jq
* Make sure that you have installed the CLIs for whichever cloud providers that you want to use. I will be using Microsoft Azure, Amazon Web Services (AWS), and Google Cloud Platform (GCP) for this example:
  * After you've installed the CLIs, be sure to configure each one so that you can use them.
  * Important: make sure that the default output for all of the CLIs is json. You do this during configuration.
  * Instructions on how to install the CLI for Azure: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest
  * Instructions on how to install the CLI for AWS: https://docs.aws.amazon.com/cli/latest/userguide/installing.html
  * Instructions on how to install the CLI for GCP: https://cloud.google.com/sdk/
* Install jq: `brew install jq` - you will need this for the scripts to successfully parse json.

# Create a key pair that you can use for all VMs
* Use an existing one or create a new one: `ssh-keygen -C "ubuntu"`
* Choose your location to store the private and public keys
* Create that key pair to exist in AWS: EC2 --> Network & Security --> Key Pairs --> Create Key Pair
  * Update `jbreese-multicloud-ubuntu` in: ./aws/params.json` --> `"ParameterKey": "KeyName"` --> ``"ParameterValue": "jbreese-multicloud-ubuntu"` to be what you named your AWS key pair to be

## From your laptop, here is an example command to get everything setup command:
It is time to setup your cluster using the `deploy.sh` script. Here is an example:
`/deploy.sh -d jbreese-test -k ../keys/ubuntu -u ubuntu -p`

Let's break down the switches:
* -d --> Argument needed: name of the DSE cluster and cloud deployments that you'd like to create (required) (e.g. jbreese-test)
* -k --> Argument needed: file of the private key on your laptop (required) (e.g. ../keys/ubuntu)
* -u --> Argument needed: username that you'll use to log into all of the servers (required) (e.g. ubuntu)
* -p --> Flag only: phased deployment will configure all DCs but will only install the first DC. You'll still be able to see the other DCs within LCM, though. You just need `-p` for this flag and nothing else. To install the subsequent DCs: go into LCM, click on the cluster -> DC -> click on the ... and then `install`. This will kick off an install job for that DC (optional) (e.g. -p)

The script could take a few minutes to deploy so be patient.

## Gotchas and things to know
* Yes, I am using public IP addresses. I realize that your security team would feel better using a VPC and private IP addresses, but this demo is all about being quick and dirty. Feel free to adjust this to fit your needs.

# Up next:
* Deploy some cool stuff and make that cluster work for you (e.g. load testing, cool demos)

# Credit to:
* Wei Deng (weideng1)
* Richard Lewis (Lewisr650)
* Collin Poczatek (cpoczatek)
* Russ Katz (russkatz)
