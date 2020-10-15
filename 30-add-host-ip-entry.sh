#!/bin/bash
HOST_IP=$(/sbin/ip route|awk '/default/ { print $3 }')
echo "$HOST_IP host.docker.internal" >> /etc/hosts
