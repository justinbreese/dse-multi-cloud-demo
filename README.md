# dse-multi-cloud-demo
I'll add some stuff here shortly...

## Create your VMs
* Go to a few of your favorite public cloud providers and create some VMs!
* Make note of the public and private IP addresses of all of the VMs
* Use the same public key on all of the servers
* Use the same username on all of the servers
* Put the private key on your laptop
* Make sure all of the DSE appropriate ports are open (e.g. nuclear option is 7000-65535)

## Set these environmental variables to whatever the values are for you:
```
export cassandra_default_password="blah"
export dsrepo_user="blah"
export dsrepo_pass="blah"
export dsrepo_key="blah"
```

## Create a text file that has your different VMs that you want in the cluster:
* Format is: public-ip:private-ip:dc-name:node-number for example, I call it as multi-list.txt below:
```
128.230.34.32:10.5.4.3:azure:0
128.230.54.32:10.5.4.8:azure:1
128.230.51.32:10.5.3.3:aws:0
128.230.76.32:10.5.3.6:aws:1
128.230.09.32:10.5.4.3:gce:0
128.230.11.32:10.5.4.4:gce:1
```

## From your laptop, run the following command:
`lcm-setup.py -lcm 13.93.183.48 -u datastax -k keys/rightscale -n dse-cluster -s Documents/temp/multi-list.txt -v 6.0.0`

Let's break down the switches:
* -u --> username that you'll use to log into all of the servers
* -k --> location of the private key on your laptop 
* -n --> name of the dse cluster that you'd like to create
* -s --> list of servers that you created in the previous step
* -v --> version of DSE that you want to deploy

The script could take a few minutes to deploy so be patient.

## Up next:
* Turn on SSL
* Deploy some cool stuff and make that cluster work for you (e.g. load testing, cool demos)

### Credit to:
* Wei Deng 
* Richard Lewis (Lewisr650)
