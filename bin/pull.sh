#!/bin/bash
set -eou pipefail

aws-creds-temp() {
    export AWS_CREDS_NAME=$(echo $1|cut -d. -f1)
    . ~/.aws_creds/$1.sh
}

for cred in $(libaws creds-ls); do (
    echo pull dns: $cred
    aws-creds-temp $cred
    mkdir -p accounts/$cred/
    libaws route53-ls > accounts/$cred/dns.txt
) done
