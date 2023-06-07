#!/bin/bash

# Get the directory path of the current script
script_dir=$(dirname "$0")

# Source the other script using a relative path
source "$script_dir/register.sh"
source "$script_dir/mappings.sh"

# To avoid silent errors
set -e

repo=$1
rev=$2

# Check if the argument is provided
if [ -n "$3" ]; then
    # If the argument is provided, assign its value to the variable
    source_folder="${3}/contracts"
    registry_path=""
else
    # If no argument is provided, assign a default value to the variable
    source_folder="contracts"
    registry_path="versions/registry-main.json"
fi

if [ "$4" = "remote" ]; then
    echo "Running script in remote setup"
    stoml="./stoml"
else
    echo "Running script in local setup"
    stoml="stoml"
fi

registry=$(jq '.' $registry_path)

files=$(find $source_folder -name "Move.toml")

for file in $files; do
    address=$(${stoml} ${file} addresses)

    if [[ $address == "ob_launchpad_v2" || $address == "ob_tests" || $address == "liquidity_layer" ]]; then
        continue  # Ignore addresses
    fi

    object_id=$(${stoml} ${file} addresses.${address})
    version=$(${stoml} ${file} package.version)
    name=$(with_prefix_to_pascal ${address})

    pkg_versions=$(jq --arg name "$name" '.[$name]' <<< "$registry")
    has_version=$(jq --arg version "$version" 'has($version)' <<< "$pkg_versions")

    if [ "$has_version" = true ]; then
        echo "$name version $version already exists"
        continue
    fi

    mod_name=$(remove_prefix ${address})

    register ${mod_name} ${repo} ${rev} $3 $4

done
