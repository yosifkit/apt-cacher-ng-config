#!/bin/bash
set -e

dir="$(dirname "$(readlink -f "$BASH_SOURCE")")"

if which multihocker > /dev/null; then
	exec multihocker "$@" "$dir/"{rawdns,apt-cacher-ng,haproxy-sks}
else
	for container in rawdns apt-cacher-ng haproxy-sks; do
		docker stop "$container" || true
		docker rm -v "$container" || true
		docker pull tianon/"$container"
	done

	docker run -d --restart=always --name rawdns \
		-p 53:53/udp -p 53:53 \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v "$dir"/.rawdns.json:/etc/rawdns.json:ro \
		tianon/rawdns rawdns /etc/rawdns.json

	docker run -d --restart=always --name haproxy-sks \
		--dns 8.8.8.8 --dns 8.8.4.4 \
		tianon/haproxy-sks

	docker run -d --restart=always --name apt-cacher-ng \
		--dns 8.8.8.8 --dns 8.8.4.4 \
		--tmpfs /var/cache/apt-cacher-ng \
		tianon/apt-cacher-ng
fi
