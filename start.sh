#!/bin/bash

if [ "$1" == "" ]; then
	echo "Usage: $0 <dockerImageTag>"
	exit 1;
fi

echo "Starting container"
logs=$PWD/logs
rm -rf $logs
mkdir -p $logs

DOCKER_IMAGE=$1

id=$(docker run --hostname=hquery-host --privileged=true -d -t -i -p 2181:2181 -p 8020:8020 -p 8888:8888 -p 11000:11000 -p 11443:11443 -p 9090:9090 -p 8088:8088 -p 19888:19888 -p 9092:9092 -p 8983:8983 -p 16000:16000 -p 16001:16001 -p 42222:22 -p 8042:8042 -p 60010:60010 -p 8080:8080 -p 7077:7077 -p 9083:9083 -p 10000:10000 $DOCKER_IMAGE)

echo "Container has ID $id"

# Get the hostname and IP inside the container
docker inspect $id > config.json
docker_hostname=`python -c 'import json; c=json.load(open("config.json")); print c[0]["Config"]["Hostname"]'`
docker_ip=`python -c 'import json; c=json.load(open("config.json")); print c[0]["NetworkSettings"]["IPAddress"]'`
rm -f config.json

echo "Updating /etc/hosts to make hbase-docker point to $docker_ip ($docker_hostname)"
if grep 'hbase-docker' /etc/hosts >/dev/null; then
  sudo sed -i "s/^.*hbase-docker.*\$/$docker_ip hbase-docker $docker_hostname/" /etc/hosts
else
  sudo sh -c "echo '$docker_ip hbase-docker $docker_hostname' >> /etc/hosts"
fi

echo "$ docker ps $id"

docker logs -f $id

