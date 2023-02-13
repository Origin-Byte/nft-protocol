#!/bin/bash

#
# Publishes a package into a new address. Assumes that Sui is running.
#

env=$(cat .env)
if [ -n "${env}" ]; then
    export $(echo "${env}" | xargs)
fi

budget="30000"
if [ -z "${GAS}" ]; then
    sui client publish --gas-budget "${budget}" .
else
    sui client publish \
        --gas "${GAS}" \
        --gas-budget "${budget}" \
        --skip-dependency-verification .
fi
