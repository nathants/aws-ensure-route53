#!/bin/bash
set -eou pipefail
for cred in $(cli-aws creds-ls); do
    bash bin/preview.sh $cred;
done
