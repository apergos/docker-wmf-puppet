#!/usr/bin/bash

if [ -n "$1" ]; then
    docker stop "puppet-$1"
else
    docker stop puppet
fi


