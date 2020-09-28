#!/usr/bin/env bash
function tellApplicable() {
    printf "true"
}

function tellVersion() {
    printf "1"
}

function run() {
    local SEP=""
    echo "["
    for file in $(git ls-files) ; do
        if [[ ( -f "$file" ) && ( $(wc -l < "$file") -gt 1337 ) ]] ; then
            printf "%s" "$SEP"
            author=$(git blame "$file" --porcelain 2>/dev/null | grep  "^author " | head -n1)
            msg="$author did a bad job and they should feel bad"
            printf "{ \"message\": \"%s\", \
                \"file\": \"%s\", \
                \"line\": 123, \
                \"type\": \"Over-length file\" \
                 }\n" "$msg" "$file"
            SEP=","
        fi
    done
    echo "]"
}

case "$3" in
    run)
        run
        ;;
    applicable)
        tellApplicable
        ;;
    version)
        tellVersion
        ;;
    default)
        echo "What? Check my version, I'm 1 (bulk)"
esac
