#!/usr/bin/bash

if [ -n "$1" ]; then
    docker start "puppet-$1"
else
    docker start puppet
fi
