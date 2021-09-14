#!/bin/bash

# take the variables as user input
read -p  "Enter Network Prefix: " netprefix
read -p "Enter Port: " porttcp
printf "\nip,port\n"
for i in $(seq 1 255); do
  timeout .1 bash -c "echo >/dev/tcp/$netprefix.$i/$porttcp" 2>/dev/null &&
    echo "$netprefix.$i,$porttcp"
done
