# dse-multi-cloud-demo
Do you want a single cluster that can span multiple public clouds all while securing your data in the process? Also, I hope you mind if you don't have any downtime... with DataStax we make it really easy to be on-prem, in the cloud, hybrid, or even multi-cloud.

Multi-cloud is starting to be very important for customers. By leveraging multiple public clouds, they're able to maintain data portability as well as being able to shop around to find the best infrastructure price for their given workloads. DataStax Enterprise provides that level of portability that they would not have by just using one public cloud.

Yes, it is possible. And yes, you can do it!

# Create your VMs
Choose your own adventure: do it yourself or use some scripts that are in the repo.

## Go to a few of your favorite public cloud providers and create some VMs!
* Make note of the public and private IP addresses of all of the VMs
* Use the same public key on all of the servers and put the private key on your laptop
* Use the same ssh key pair for all of the VMs
* Use the same username on all of the servers
* Make sure all of the DSE appropriate ports are open. For a list of all of the ports go to: https://docs.datastax.com/en/dse/6.0/dse-admin/datastax_enterprise/security/secFirewallPorts.html
* If you don't want to open up the specific ports for DSE, then you can do the nuclear option and open all all of the following ports: 7000-65535

## Use the scripts in the repo
* Check out the `iaas` directory in this repo for a full README on how this works
* There is complete automation for Azure, GCP, and AWS

## Set these environmental variables in your .bash_profile:
```
export cassandra_default_password="blah"
export academy_user="blah"
export academy_pass="blah"
export academy_token="blah"
```
Be sure to replace `blah` with your credentials. If you don't have credentials for DataStax Academy, then go and sign up for it at http://academy.datastax.com - it's free!  Be sure to create a download key (token) for your downloads too.

# Create a text file that has your different VMs that you want in the cluster:
Again, choose your own adventure...
* If you're leveraging the scripts in the `iaas` folder to create your infrastructure, then you probably already put your list together via the `gather_ips.sh` script. If you already have your list, then skip the rest of this section. If you do not have your list yet, then go back to the iaas/README.md and use revisit the `gather_ips.sh` section.
* Otherwise, if you need to put your list together manually:
  * Create a generic text file and format your VMs like this: `public-ip:private-ip:dc-name:node-number` for example, I call it as server-list below:
```
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

# From your laptop, here is an example command to get everything setup command:
It is time to setup your cluster using the `setup.py` script. Here is an example:

`python dse-multi-cloud-demo/setup.py -lcm 52.160.36.16 -u ubuntu -k keys/ubuntu -n dse-cluster -s dse-multi-cloud-demo/server-list`

Let's break down the switches:
* -lcm --> this is the public IP address of the server that you wish to designate as the DataStax OpsCenter Server; this will be the main server that all of the other nodes will be configured by. **Make sure that this entry is not in your server list file. We don't want to make your OpsCenter VM a DSE node as well**
* -u --> username that you'll use to log into all of the servers
* -k --> location of the private key on your laptop
* -n --> name of the dse cluster that you'd like to create
* -s --> list of servers that you created in the previous step

The script could take a few minutes to deploy so be patient.

# Gotchas and things to know
* Yes, I am using public IP addresses. I realize that your security team would feel better using a VPC and private IP addresses, but this demo is all about being quick and dirty. Feel free to adjust this to fit your needs.
* Make sure that Python is installed on all of the VMs

# Up next:
* Deploy some cool stuff and make that cluster work for you (e.g. load testing, cool demos)

# Credit to:
* Wei Deng (weideng1)
* Richard Lewis (Lewisr650)
* Collin Poczatek (cpoczatek)
