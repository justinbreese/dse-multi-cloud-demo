import yaml
import random
import string

def GenerateConfig(context):
    config = {'resources': []}

    zonal_clusters = {
        'name': 'clusters-' + context.env['name'],
        'type': 'regional_multi_vm.py',
        'properties': {
            'sourceImage': 'https://www.googleapis.com/compute/v1/projects/datastax-public/global/images/datastax-enterprise-ubuntu-1604-xenial-v20180424',
            'zones': context.properties['zones'],
            'machineType': context.properties['machineType'],
            'network': context.properties['network'],
            'numberOfVMReplicas': context.properties['nodesPerZone'],
            'disks': [
                {
                    'deviceName': 'vm-data-disk',
                    'type': 'PERSISTENT',
                    'boot': 'false',
                    'autoDelete': 'true',
                    'initializeParams': {
                        'diskType': context.properties['dataDiskType'],
                        'diskSizeGb': context.properties['diskSize']
                    }
                }
            ],
            'bootDiskType': 'pd-standard',
            'bootDiskSizeGb': 20,
            'metadata': {
                'items': [
                    {
                        'key': 'ssh-keys',
                        'value': 'ubuntu:ssh-rsa ' + context.properties['sshKeyValue']# + ' ubuntu'
                    }
                ]
            },
            'tags': {
                'items': [
                   context.env['deployment']
                ]
            }
        }
    }


    config['resources'].append(zonal_clusters)

    return yaml.dump(config)
