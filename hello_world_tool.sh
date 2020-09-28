#!/usr/bin/env bash
commit=$2
cmd=$3

function version() {
    echo 1
}

function applicable() {
    echo "true"
}

function run() {
    echo "[{ \"type\": \"Hello World\", \
            \"message\": \"Hello World!\", \
            \"file\": \"N/A\", \
            \"line\": 0 \
          }]"
}

if [[ "$cmd" = "run" ]] ; then
  run
fi
if [[ "$cmd" = "applicable" ]] ; then
  applicable
fi
if [[ "$cmd" = "version" ]] ; then
  version
fi