#!/bin/bash

# usage : ./ping_sweep <first three octet>

for i in `seq 1 254`; do
ping -c 1 $1.$i | grep "64 bytes" | cut -d " " -f 4 | tr -d ":" &
done
