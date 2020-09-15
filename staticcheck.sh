#!/usr/bin/env bash
function tellApplicable() {
    files=$(git ls-files | egrep '.go$' | head)
    res="broken"
    if [[ -z "$files" ]] ; then
        res="false"
    else
        res="true"
    fi
    printf "%s\n" "$res"
}

function tellVersion() {
    echo "1"
}

function getTool() {
  pushd /tmp >/dev/null
  apt update >/dev/null && apt install -y golang >/dev/null
  curl -LO https://raw.githubusercontent.com/smagill/secdev20/master/staticcheck
  chmod a+x staticcheck
  popd >/dev/null
}

function emit_results() {
  echo "$1" | \
    jq --slurp | \
        jq '.[] | .file = .location.file | .line = .location.line | .type = .code | del(.location) | del(.severity) | del(.code) | del(.end)' | \
            jq --slurp
}

function run() {
    getTool
    go get ./...
    raw_results=$(/tmp/staticcheck -f json -fail "" ./...)
    emit_results "$raw_results"
}

case "$3" in
    run)
        run
        ;;
    applicable)
        tellApplicable
        ;;
    *)
        tellVersion
        ;;
esac
