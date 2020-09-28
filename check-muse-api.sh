#!/usr/bin/env bash

function checkVersion() {
    local result
    result=$($script "$test_repo" "$test_commit" version | jq .)
    if [[ "$result" = "1" ]] ; then
        echo "$script version    GOOD"
    else
        echo "$script version    BAD (returned $result)"
        echo "  should emit '1' to indicate API version 1."
    fi
}

function checkApplicable() {
    local aresult
    aresult=$($script "$test_repo" "$test_commit" applicable | jq .)
    if [[ ( "$aresult" = "true" ) || ( "$aresult" = "false" ) ]] ; then
        echo "$script applicable GOOD"
    else
        echo "$script applicable BAD (returned '$aresult')"
        echo "  should emit a boolean (true or false)"
    fi
}

function checkRun() {
    if [[ -d "$test_repo" ]] ; then
        local result
        result=$($script "$test_repo" "$test_commit" run)
        toptype=$(echo "$result" | jq 'type')
        if [[ ! ( "$toptype" = '"array"' ) ]] ; then
            echo "$script run   BAD - results should be an array"
            exit 1
        fi
        correctLength=$(echo "$result" | jq 'length')
        withFile=$(echo "$result" | jq 'map(.file) | map(strings) | length')
        withType=$(echo "$result" | jq 'map(.type) | map(strings) | length')
        withMessage=$(echo "$result" | jq 'map(.message) | map(strings) | length')
        withLine=$(echo "$result" | jq 'map(.line) | map(numbers) | length')
        if [[  ! ( "$correctLength" = "$withFile" ) ]] ; then
            echo "$script run   BAD - bad or missing 'file' field(s)."
            exit 1
        fi
        if [[  ! ( "$correctLength" = "$withType" ) ]] ; then
            echo "$script run   BAD - bad or missing 'type' field(s)."
            exit 1
        fi
        if [[  ! ( "$correctLength" = "$withMessage" ) ]] ; then
            echo "$script run   BAD- bad or missing 'message' field(s)."
            exit 1
        fi
        if [[  ! ( "$correctLength" = "$withLine" ) ]] ; then
            echo "$script run   BAD - bad or missing 'line' field(s)."
            exit 1
        fi
        echo "$script run        GOOD"
    else
        echo "No repository specified on the command line."
        echo "Not checking the 'run' functionallity due to missing test repository."
    fi
}

function checkDeps() {
    if [[ ! ( -f "$(command -v jq)" ) ]] ; then
        echo "Missing jq"
        exit 1
    fi
    if [[ ! ( -f "$(command -v git)" ) ]] ; then
        echo "Missing git"
        exit 1
    fi
}

function main() {
    checkDeps
    script="$(pwd)/$1"
    test_repo=$2
    test_commit=""
    echo "Checking script '$script'"

    if [[ ! ( -z "$test_repo" ) ]] ; then
        pushd "$test_repo" || exit 1
        test_commit=$(git rev-parse HEAD 2>/dev/null)
    else
        test_repo="some_repo_directory"
        test_commit="some_commit"
    fi
    checkVersion
    checkApplicable
    checkRun
}

main "$@"
