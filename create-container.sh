#!/bin/bash
if [ -n "$1" ]; then
    tag="$1"
else
    tag="latest"
fi
docker run -d -name puppet -v /sys/fs/selinux:/selinux:ro "ariel/puppet:${tag}"
