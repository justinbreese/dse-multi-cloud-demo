#!/usr/bin/env python
# Example provisioning API usage script.  (C) DataStax, 2018.  All Rights Reserved
#
# Needs these OS environmental variables pre-defined: lcm_server, cassandra_default_password, academy_user, academy_pass, and academy_token
# command line parameter with node IP/DC in the following format:
# public_IP:private_IP:DC_name:node_number
#
# This script will: install DataStax OpsCenter on a given VM, then - via LCM - setup the download repo, SSH credentials for contacting the other VMs,
# create configuration profile, create a cluster, datacenter(s), nodes, and then run an install job on the given datacenter(s)

# python ./setup.py -k key/ubuntu -s server-list -n awesome-demo -u ubuntu -v 3 -o aws

import os
import sys
import requests
import json
import threading
import argparse
import subprocess
import webbrowser
import time

# Configurable args
ap = argparse.ArgumentParser()
ap.add_argument("-lcm", "--LCM_server_ip", required=False,
	help="public IP address of the LCM server")
ap.add_argument("-k", "--ssh_key", required=True,
	help="private key to be used")
ap.add_argument("-n", "--cluster_name", required=True,
	help="name of the cluster that you want to create")
ap.add_argument("-s", "--server_list", required=True,
	help="list of servers to be added to the new cluster")
ap.add_argument("-u", "--user", required=True,
	help="username for the server")
ap.add_argument("-p", "--phased", required=False, action='store_true',
	help="install the first DC and then setup the config for the other DCs?")

args = vars(ap.parse_args())

ssh_key = args["ssh_key"]
cluster_name = args["cluster_name"]
server_list = args["server_list"]
username = args["user"]
phased_deploy = args["phased"]
dse_ver = "6.0.4"


# open up the server list and pull out the predefined OpsCenter VM
with open(server_list, 'r') as server_list_file:
    server_list = server_list_file.read().split()

for host in server_list:
    node_ip = host.split(":")[0]
    data_center = host.split(":")[2]

    if data_center in ["Ops", "ops", "OpsCenter", "opscenter", "Opscenter"]:
		server_ip = node_ip

repo_user = os.environ.get('academy_user').strip()
repo_pass = os.environ.get('academy_pass').strip()
download_token = os.environ.get('academy_token').strip()

#SSH into the OpsCenter/LCM server, install the JDK, install OpsCenter
bashCommand = 'ssh -o StrictHostKeyChecking=accept-new -i '+ ssh_key+ ' '+ username+'@'+server_ip+' \'sudo apt-get install -y python software-properties-common; \
sudo apt-add-repository -y ppa:openjdk-r/ppa; \
sudo apt-get update; \
sudo apt-get install -y openjdk-8-jdk; \
echo "deb https://'+repo_user+':'+download_token+'@debian.datastax.com/enterprise \
stable main" | sudo tee -a /etc/apt/sources.list.d/datastax.sources.list; \
curl -L https://debian.datastax.com/debian/repo_key | sudo apt-key add - ; \
sudo apt-get update; sudo apt-get install opscenter; sudo service opscenterd start;\
\' 2>/dev/null'

output = subprocess.check_output(['bash','-c', bashCommand])

base_url = 'http://%s:8888/api/v2/lcm/' % server_ip
base_api_url = 'http://'+server_ip+':8888/'
cassandra_default_password = os.environ.get('cassandra_default_password').strip()
opscenter_session = os.environ.get('opscenter_session', '')

# Wait for OpsCenter to finish starting up by polling the API until we get a
# 20x response.

# Works by attaching a custom retry mechanism to the requests session, this is
# documented at:
# http://urllib3.readthedocs.io/en/latest/reference/urllib3.util.html
# https://www.peterbe.com/plog/best-practice-with-retries-with-requests
#
# This particular session waits a max around 4 minutes.
# This affects only requests invoked via the custom-session, not requests
# invoked via requests.post or requests.get, for example.
#
# By default session.get(base_url) will silently block until OpsCenter comes up.
# This StackOverflow answer shows how to turn up the verbosity on third-party
# loggers (inluding requests and retry) and send them to stdout, but it will
# make the rest of script extremely verbose as well:
# https://stackoverflow.com/a/14058475
session = requests.Session()
retry = requests.packages.urllib3.util.retry.Retry(
    total=8,          # Max retry attempts
    backoff_factor=1, # Sleeps for [ 1s, 2s, 4s, ... ]
                      # Stops growing at 120 seconds
)
adapter = requests.adapters.HTTPAdapter(max_retries=retry)
session.mount('http://', adapter)
session.mount('https://', adapter)
session.get(base_url)

#list out all of the arguments that have been used for the command
print str(sys.argv)

def do_post(url, post_data):
    result = requests.post(base_url + url,
                           data=json.dumps(post_data),
                           headers={'Content-Type': 'application/json', 'opscenter-session': opscenter_session})
    print repr(result.text)
    result_data = json.loads(result.text)
    return result_data

# setup the repository for where you want to download DSE from
repository_response = do_post("repositories/",
    {"name": "dse-public-repo",
        "username": repo_user,
        "password": repo_pass,})

repository_id = repository_response['id']

# setup the ssh credential section for LCM
with open(ssh_key, 'r') as myfile:
        privateKey=myfile.read()
machine_credential_response = do_post("machine_credentials/",
     {"name": cluster_name,
      "login-user": username,
      "become-mode": "sudo",
      "ssh-private-key": privateKey,
	  "use-ssh-keys": True
    }
)
machine_credential_id = machine_credential_response['id']

# setup the config profile for LCM
cluster_profile_response = do_post("config_profiles/",
    {"name": cluster_name,
     "datastax-version": dse_ver,
	 'json': {'cassandra-yaml' : {
	 			  'num_tokens' : 8,
                  'client_encryption_options' : { 'enabled' : True },
                 'server_encryption_options' : { 'internode_encryption' : 'all',
							                      'require_client_auth' : True,
							                      'require_endpoint_verification' : False
                 								}
				 				},
             },
     "comment": 'LCM provisioned as %s' % cluster_name})

cluster_profile_id = cluster_profile_response['id']

# setup the cluster with the recently created config profile
make_cluster_response = do_post("clusters/",
    {"name": cluster_name,
     "repository-id": repository_id,
     "machine-credential-id": machine_credential_id,
     "old-password": "cassandra",
     "new-password": cassandra_default_password,
     "config-profile-id": cluster_profile_id})
cluster_id = make_cluster_response['id']

data_centers = set()

# open up the server list (provided by -s blah) within LCM and start creating the mapping of DCs and nodes
for host in server_list:
    data_centers.add(host.split(":")[2])

# create the DCs for the recently created cluster
data_center_ids = {}
for data_center in data_centers:
	if data_center not in ["Ops", "ops", "OpsCenter", "opscenter", "Opscenter"]:
		make_dc_response = do_post("datacenters/",
	        {"name": data_center,
	         "cluster-id": cluster_id,
	         "solr-enabled": True,
	         "spark-enabled": True,
	         "graph-enabled": True}
			 )
		dc_id = make_dc_response['id']
		data_center_ids[data_center] = dc_id

# create the nodes for the recently created DCs
for host in server_list:
	node_ip = host.split(":")[0]
	private_ip = host.split(":")[1]
	data_center = host.split(":")[2]
	node_idx = host.split(":")[3]
	if data_center not in ["Ops", "ops", "OpsCenter", "opscenter", "Opscenter"]:
		make_node_response = do_post("nodes/",
	        {"name": "node" + str(node_idx) + "_" + node_ip,
	         "listen-address": private_ip,
	         "native-transport-address": "0.0.0.0",
		     "broadcast-address": node_ip,
	         "native-transport-broadcast-address": node_ip,
	         "ssh-management-address": node_ip,
	         "datacenter-id": data_center_ids[data_center],
	         "rack": "rack1"})

# Request an install job to execute the installation and configuration of the
# cluster. Until this point, we've been describing desired state. Now LCM will
# execute the changes necessary to achieve that state.
install_job = do_post("actions/install",
                     {"job-type":"install",
                      "job-scope":"cluster",
                      "resource-id":cluster_id,
					  "concurrency-strategy": "cluster-at-a-time",
                      "continue-on-error":"false"})
job_id = install_job['id']
print("DataStax OpsCenter can be found at: http://%s:8888" % server_ip)
print("The installation of DataStax Enterprise is complete.")
# open up a new browser tab that shows the deployment job that you just started
webbrowser.open_new_tab('http://'+server_ip+':8888/opscenter/lcm.html#/jobs/'+job_id)
