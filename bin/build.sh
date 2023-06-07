#!/bin/bash

cd ./contracts/allowlist
sui move build
cd ..

cd ./authlist
sui move build
cd ..

cd ./permissions
sui move build
cd ..

cd ./pseudorandom
sui move build
cd ..

cd ./utils
sui move build
cd ..

cd ./kiosk
sui move build
cd ..

cd ./launchpad
sui move build
cd ..

cd ./liquidity_layer_v1
sui move build
cd ..

cd ./liquidity_layer
sui move build
cd ..

cd ./nft_protocol
sui move build

cd ../..
