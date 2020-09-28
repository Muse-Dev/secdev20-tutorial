#!/usr/bin/env bash
commit=$2
cmd=$3

function version() {
    echo 1
}

function applicable() {
    echo "true"
}

function gettool() {
  apt update >/dev/null && apt install -y golang >/dev/null
  pushd /tmp >/dev/null
  curl -LO https://raw.githubusercontent.com/smagill/secdev20/master/staticcheck
  chmod a+x staticcheck
  popd >/dev/null
}

function emit_results() { 
  echo "$1"  | \
    jq --slurp '.[] | .file = .location.file | .line = .location.line | .type = .code | del(.location) | del(.severity) |  del(.code) | del(.end)' | jq --slurp
}

function run() {
  gettool
  go get ./...
  raw_results=$(/tmp/staticcheck -f json -fail "" ./...)
  emit_results "$raw_results"
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