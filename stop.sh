#!/bin/bash

if ! [ -e "$(dirname "$0")/settings" ]; then
  echo "settings file missing!" >&2
  exit 1
fi

. "$(dirname "$0")/settings"

for i in `seq 1 $num_nodes`; do
    docker-machine stop node-$i
done


