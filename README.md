# dse-multi-cloud-demo
How to simulate a multi-cloud deployment with your laptop acting as a second DC with DataStax Enterprise (DSE)

Have you ever wanted to turn your laptop into a second DC for a cluster within DataStax Enterprise? Oh you haven't? Oh well… I did, so look no further. Really though, the reason I did this is to show how trivial it is to run in a multi-cloud scenario. Something that can resonate: "It is really easy, I can join my laptop up with the cluster in a matter of minutes."

## Prerequisites:
* On your laptop or equivalent: start with a fresh DSE install or delete your existing DSE data folder
* Have access to a smaller cluster - e.g. setup a quick 3 node cluster via AWS/Azure/GCP
* Do you have a public IP address? If so, it must be nice being rich! Otherwise, the rest of us are most likely going through a router. Be sure to have access to your router (e.g. since you don't have a public IP address) so you can do some port forwarding

## Changes to make:
### Cassandra.yaml
* Make sure the cluster name matches to the one that you're joining; find out the name of your AWS/Azure/GCP cluster and make it the name of the cluster on your laptop
* Match the seeds to the seeds of the cluster
* Commented out `listen_address`
* Uncommented `listen_interface`, set it to your Ethernet interface (find this by going to `ifconfig` (Mac) or `ipconfig` (PC), mine was 'en0' for example); this makes it so you don't have to worry if your local IP address changes.
* `Broadcast_address` = your public IP address. You need to find the IP address of your Internet service. You can find this by going here: http://lmgtfy.com/?q=what+is+my+ip+address
* Comment out `RPC_address`
* Uncommented `RPC_interface`, set it to your Ethernet interface (should be the same as step #4)
* Make sure the snitch matches to the others that you're joining. But really, `gossipingpropertyfilesnitch` is the only snitch!

### Cassandra-rackdcproperties
* Make sure the rack names match
* Uncomment out `Prefer_local=true`
* Make sure your laptop has another DC name (e.g. if DC1 is the name of the small cluster that you're joining, call this one DC2); doing that will ensure that Cassandra will communicate over the public IP addresses.

### Routing: if you have a public IP address then skip this. Otherwise…
* Log into your router, and figure how to do port forwarding
* Port forward basically TCP 4000-65000 to your private IP address; find this by going to `ifconfig` or `ipconfig` (e.g. 192.168.1.23)

# Are you done yet?
Once done with this, start up DSE and you're up and running!

Finally, you can brag to everyone that you know that you have created your own multi-cloud DSE deployment with your laptop acting as its own DC. People will fear you, you will acquire a lot of friends, and you are one step closer to World domination.
