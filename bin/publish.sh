#!/bin/bash

#
# Publishes a package into a new address. Assumes that Sui is running.
#

env=$(cat .env)
if [ -n "${env}" ]; then
    export $(echo "${env}" | xargs)
fi

# if GAS is not defined and jq dependency is defined, grab first gas object
if [ -z "${GAS}" ] && [ -x "$(command -v jq)" ]; then
    GAS="$(sui client gas --json | jq -r '.[0].id.id')"
fi

read -p "Use ${GAS} as gas object? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    sui client publish \
        --gas "${GAS}" \
        --gas-budget 30000 .
else
    echo "Aborting"
fi
