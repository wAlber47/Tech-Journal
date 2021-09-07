#!/bin/bash

# Takes the file name as user input, could also input a path
read -p "Enter Host File name: " hostfile
read -p "Enter Port File name: " portfile

echo "host,port"
for host in $(cat $hostfile); do
  for port in $(cat $portfile); do
    timeout .1 bash -c "echo >/dev/tcp/$host/$port" 2>/dev/null &&
      echo "$host,$port"
  done
done
