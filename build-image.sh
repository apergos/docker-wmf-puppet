#!/bin/bash

if [ -n "$1" ]; then
    name="ariel/puppet:$1"
else
    name="ariel/puppet"
fi

docker build -rm -t "$name" .
