#!/bin/bash

# takes the variables as user input
read -p "Enter Network Prefix: " netprefix
read -p "Enter DNS Server IP Address: " dnsserver

printf "\nDNS Resolution for $netprefix\n"
for i in $(seq 1 255); do
  nslookup $netprefix.$i $dnsserver | grep "name"
done
