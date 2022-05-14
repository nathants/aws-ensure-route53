#!/bin/bash
set -eou pipefail

for cred in $(libaws creds-ls); do
    bash bin/ensure.sh $cred;
done
