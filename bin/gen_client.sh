#!/bin/bash

# Navigate to the target directory
cd client/

# Find and delete all files and directories except gem.toml
find . -type f ! -name 'gen.toml' -exec rm -f {} +

sui-client-gen

pnpm eslint . --fix

cd ../
