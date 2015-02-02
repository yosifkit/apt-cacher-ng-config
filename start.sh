#!/bin/bash
set -e

dir="$(dirname "$(readlink -f $BASH_SOURCE)")"

docker pull tianon/rawdns
docker pull tianon/apt-cacher-ng

docker run -d --restart=always --name rawdns \
	-p 53:53/udp -p 53:53 \
	-v /var/run/docker.sock:/var/run/docker.sock \
	-v "$dir"/dns.json:/etc/rawdns.json:ro \
	tianon/rawdns rawdns /etc/rawdns.json

docker run -d --restart=always --name apt-cacher-ng tianon/rawdns
