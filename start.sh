#!/bin/bash
set -e

dir="$(dirname "$(readlink -f "$BASH_SOURCE")")"

docker stop rawdns || true
docker stop apt-cacher-ng || true
docker rm -v rawdns || true
docker rm -v apt-cacher-ng || true

docker pull tianon/rawdns
docker pull tianon/apt-cacher-ng

docker run -d --restart=always --name rawdns \
	-p 53:53/udp -p 53:53 \
	-v /var/run/docker.sock:/var/run/docker.sock \
	-v "$dir"/dns.json:/etc/rawdns.json:ro \
	tianon/rawdns rawdns /etc/rawdns.json

docker run -d --restart=always --name apt-cacher-ng \
	--dns 8.8.8.8 --dns 8.8.4.4 \
	-v /tmp/apt-cacher-ng:/var/cache/apt-cacher-ng \
	tianon/apt-cacher-ng
