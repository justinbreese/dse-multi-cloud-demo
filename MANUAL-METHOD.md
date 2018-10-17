# The manual method
This way requires you to do more manual work on your end.
* You will create deployments in each individual cloud provider; you can use my provided scripts or do it manually
* Gather the IP addresses; via scripts or manually
* Run `setup.py` to manually start the install process

## Create your VMs
Choose your own adventure: do it yourself or use some scripts that are in the repo.

## Go to a few of your favorite public cloud providers and create some VMs!
* Make note of the public and private IP addresses of all of the VMs
* Use the same public key on all of the servers and put the private key on your laptop;
  * Either use an existing one or create a new one: `ssh-keygen -C "ubuntu"`
* Use the same username on all of the servers (e.g. ubuntu)
* Make sure all of the DSE appropriate ports are open. For a list of all of the ports go to: https://docs.datastax.com/en/dse/6.0/dse-admin/datastax_enterprise/security/secFirewallPorts.html
* If you don't want to open up the specific ports for DSE, then you can do the nuclear option and open all all of the following ports: 7000-65535; fine for demos, but not fit for production by any means

## Use the scripts in the repo
* Check out the `iaas` directory in this repo for a full README on how this works
* This is complete automation for provisioning the IaaS for Azure, GCP, and AWS

## Create a text file that has your different VMs that you want in the cluster:
Again, choose your own adventure...
* If you're leveraging the scripts in the `iaas` folder to create your infrastructure, then you probably already put your list together via the `gather_ips.sh` script. If you already have your list, then skip the rest of this section. If you do not have your list yet, then go back to the iaas/README.md and use revisit the `gather_ips.sh` section.
* Otherwise, if you need to put your list together manually:
  * Create a generic text file and format your VMs like this: `public-ip:private-ip:dc-name:node-number` for example, I call it as server-list below:
```
18.236.78.240:172.31.16.53:ops:0
18.236.78.240:172.31.16.53:aws:0
34.217.211.58:172.31.21.235:aws:1
34.208.176.38:172.31.17.235:aws:2
35.224.38.177:10.128.0.2:gcp:0
35.193.235.66:10.128.0.3:gcp:1
35.192.167.240:10.128.0.4:gcp:2
104.42.173.94:172.16.0.4:azure:0
104.42.168.14:172.16.0.4:azure:1
104.42.173.219:172.16.0.4:azure:2
```
* **Very important:** decide which VM you want to be acting as your OpsCenter node:
  * Make a note of the public IP address
  * Delete that entry from your `server-list` file - We don't want to make your OpsCenter VM a DSE node as well

## From your laptop, here is an example command to get everything setup command:
It is time to setup your cluster using the `setup.py` script. Here is an example:
`python setup.py -u ubuntu -k keys/ubuntu -n dse-cluster -s server-list`

Let's break down the switches:
* -u --> Argument needed: username that you'll use to log into all of the servers (required) (e.g. ubuntu)
* -k --> Argument needed: file of the private key on your laptop (required) (e.g. ../keys/ubuntu)
* -n --> Argument needed: name of the DSE cluster and cloud deployments that you'd like to create (required) (e.g. jbreese-test)
* -s --> Argument needed: file of the list of servers that you created in the previous step (required) (e.g. server-list)
* -p --> Flag only: phased deployment will configure all DCs but will only install the first DC. You'll still be able to see the other DCs within LCM, though. You just need `-p` for this flag and nothing else. To install the subsequent DCs: go into LCM, click on the cluster -> DC -> click on the ... and then `install`. This will kick off an install job for that DC (optional) (e.g. -p)

The script could take a few minutes to deploy so be patient.
