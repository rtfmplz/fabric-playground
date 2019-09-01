#!/bin/bash

## Unit-Testable Shell Scripts (http://eradman.com/posts/ut-shell-scripts.html)
typeset -i tests_run=0

function try { this="$1"; }

trap 'printf "$0: exit code $? on line $LINENO\nFAIL: $this\n"; exit 1' ERR

function assert {
    let tests_run+=1
    [ "$1" = "$2" ] && { echo -n "."; return; }
    printf "\nFAIL: $this\n'$1' != '$2'\n"; exit 1
}
## end

## IP:PORT 접속 테스트
function get_conn {
  echo $(curl $1 -k -s -v --stderr - | grep -a 'Connected' | awk '{ print $4":"$7 }')
}


## test https 
# curl --resolve peer1:127.0.0.1 https://peer1:57050 --insecure -v -stderr - | grep 'common name' | awk '{ print $4 }'
function get_common_name {
  echo $(curl --resolve $1:$2 https://$1 --insecure -v -stderr - | grep 'common name' | awk '{ print $4 }')
}