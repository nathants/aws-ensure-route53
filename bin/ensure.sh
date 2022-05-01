#!/bin/bash
set -eou pipefail

cred=$1

echo ensure dns: $cred

aws-creds-temp() {
    export AWS_CREDS_NAME=$(echo $1|cut -d. -f1)
    . ~/.aws_creds/$1.sh
}

(
    aws-creds-temp $cred
    cat accounts/$cred/dns.txt | while read line; do
        bash -c "cli-aws route53-ensure-record $line"
    done
)
