#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

#start user defined
#You will need to aws vars.

CLUSTERNAME='ice-consul'
EC2REGION='us-west-2'
EC2_CONSUL_KEY='%ENVSHORT%-ice-consul-host-us-west-2' #this is what links the consul instances
EC2_CONSUL_VALUE='%ENVSHORT%-ice-consul-host-us-west-2' #they are just aws tags
HOST_TYPE='m4.large'
EC2AMI='ami-3408c34c'
EC2IAM='your-iam-role'
EC2VPC='vpc-b285edd7'
EC2SUBNET1='subnet-efd2da8a' #you can make these the same if you
EC2SUBNET2='subnet-18d04d6f' #don't care about HA
EC2SECURITY_GROUP='admin-servers' #this doesn't matter if you don't use an LB
EC2SECURITY_GROUP_ID='sg-4c964728'
EC2KEYPAIR='name-of-your-key'
EC2KEYPATH='~/path/to/your/key.pem'
ENGINEURL='https://test.docker.com' #last I know, you have to use test. It has undocumented docker features that I need.
SWARMIDENTIFIER='%ENVSHORT%'
NUMOFMANAGERS='4'
NUMOFNODES='4'
OTHERTAGS=',Name,us-west-2-%ENVLONG%-ice-vault-consul'\
',Creator,YOURTEAM'\
',Environment,%ENVLONG%'\
',Location,us-west-2'\
',Contact,your_email@your_email.com'
#must begin with a comma (e.g. ,key1,value1,key2,value2)

#end user defined
#$(docker-machine ls --filter name=manager1 | grep Running | grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}')
TOTALNODES=$(expr $NUMOFNODES + $NUMOFMANAGERS)
CONSULSECONDARYNODES=$(expr $NUMOFNODES + $NUMOFMANAGERS - 1)
RANDOM=$RANDOM










#start logic. Line numbers are important here since I'm doing loops based on
#the vars above. There's probably a better way, but this works

templates=`find $DIR -type f | grep \.template$`
for template in $templates ; do
  final=$(echo $template | awk -F'\\.template$' '{print $1}')
  cat $template > $final
  for var in `head -46 $DIR/make.sh | grep "[^a-z]=" | awk -F'=' '{print $1}'`; do
    interp=$(eval echo $`echo ${var}`)
    sed -i "s#\%$var\%#$interp#g" $final
  done
done

stacks=`find $DIR -type f | grep -v machines | grep \.yaml$`
services=`find $DIR -type f | grep -v machines | grep \.json$`
bins=`find $DIR -type f | grep -v machines | grep \.bash$`

for stack in $stacks; do
  mv $stack $DIR/stacks 2>/dev/null
done

for service in $services; do
  mv $service $DIR/service-configurations 2>/dev/null
done

for bin in $bins; do
  chmod 700 $bin
  mv $bin $DIR/bin 2>/dev/null
done
