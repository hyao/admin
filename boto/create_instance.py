#!/usr/bin/env python
# coding: utf-8

#run source ./credentials/aws-env before running this script

import time
from boto_utils import connect

#could use boto.ec2.connect_to_region(region_name, **kw_params)

AWS_ACCESS_KEY_ID = 
AWS_SECRET_ACCESS_KEY = 
keypair_name = 'mykeyname'

conn = connect(AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, region='us-west-2')

#new_keypair = conn.create_key_pair(keypair_name)
#new_keypair.save('./credentials')

#start instance
reservation = conn.run_instances(
    'ami-8e109ebe',                 #Ubuntu LTS 12.04.1
    key_name = keypair_name, 
    instance_type = 't1.micro')

print 'reservation: ', reservation
#get instance and status
node = reservation.instances[0]
print 'instance:', node, node.update()

#wait till instance's running
print 'waiting for instance to launch...'
time.sleep(10)
print 'instance dns:', node.dns_name

#conn.authorize_security_group(group_name='default', ip_protocol='tcp', from_port=22, to_port=22, cidr_ip='0.0.0.0/0')
