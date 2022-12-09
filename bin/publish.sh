#!/bin/bash

#
# Publishes a package into a new address. Assumes that Sui is running.
#

export $(cat .env | xargs)

sui client publish \
    --gas "${GAS}" \
    --gas-budget 30000 .
