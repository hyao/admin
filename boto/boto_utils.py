import boto
from boto.ec2.connection import EC2Connection

AWS_ACCESS_KEY_ID=''
AWS_SECRET_ACCESS_KEY=''

aws_regions = (u'eu-west-1', u'sa-east-1', u'us-east-1', u'ap-northeast-1',
        u'us-west-2', u'us-west-1', u'ap-southeast-1', u'ap-southeast-2')

def connect(aws_id, aws_key, region='us-east-1'):
    conn = EC2Connection( aws_id, aws_key )
    all_regions = conn.get_all_regions()
    #check to make sure get_all_regions are still in the same order
    #for i in len(aws_regions):
    #    assert all_regions[i].name == aws_regions[i]
    
    if region == 'us-east-1':
        print 'connected to region: ', conn.region.name
        return conn
    elif region in aws_regions:
        for r in all_regions:
            if r.name == region:
                conn = r.connect()
                break
        print 'connected to region: ', conn.region.name
        return conn
    else:
        print 'incorrect region!'
        raise SystemExit

