#!/bin/bash

#
# Mapping & Util Functions
#

# Function to convert PascalCase to snake_case
pascal_to_snake() {
  echo "$1" | sed 's/\([^A-Z]\)\([A-Z]\)/\1_\2/g' | tr '[:upper:]' '[:lower:]'
}

# Maps folder names to actual package_names
add_prefix() {
    # Create an indexed array to store the mappings
    declare -a mappings=("nft_protocol" "launchpad" "liquidity_layer" "liquidity_layer_v1" "allowlist" "authlist" "kiosk" "permissions" "pseudorandom" "request" "utils" "originmate" "sui")
    declare -a variables=("nft_protocol" "ob_launchpad" "liquidity_layer" "liquidity_layer_v1" "ob_allowlist" "ob_authlist" "ob_kiosk" "ob_permissions" "ob_pseudorandom" "ob_request" "ob_utils" "originmate" "sui")

    # Find the index of the provided string
    index=-1
    for i in "${!mappings[@]}"; do
        if [[ "${mappings[i]}" == "$1" ]]; then
            index=$i
            break
        fi
    done

    # Check if the provided string is recognized
    if [[ $index -eq -1 ]]; then
        echo "Unrecognized string: $1" >&2
        exit 1
    fi


    # Access the mapped value
    echo "${variables[index]}"
}

# Maps toml-parsed names to Pascal strings
lowercase_to_pascal() {
    # Create an indexed array to store the mappings
    declare -a mappings=("nftprotocol" "launchpad" "liquiditylayer" "liquiditylayerv1" "allowlist" "authlist" "kiosk" "permissions" "pseudorandom" "request" "utils" "originmate" "sui")
    declare -a variables=("NftProtocol" "Launchpad" "LiquidityLayer" "LiquidityLayerV1" "Allowlist" "Authlist" "Kiosk" "Permissions" "Pseudorandom" "Request" "Utils" "Originmate" "Sui")

    # Find the index of the provided string
    index=-1
    for i in "${!mappings[@]}"; do
        if [[ "${mappings[i]}" == "$1" ]]; then
            index=$i
            break
        fi
    done

    # Check if the provided string is recognized
    if [[ $index -eq -1 ]]; then
        echo "Unrecognized string: $1" >&2
        exit 1
    fi


    # Access the mapped value
    echo "${variables[index]}"
}

# Parsers BuildInfo.yml and returns the object ID of the queried package
parse_build_yaml() {
    folder_name="$1"
    pascal_name="$2"
    mod_name="$3"

    yaml_file="${source_folder}/${folder_name}/build/${pascal_name}/BuildInfo.yaml"

    key_1="compiled_package_info"
    key_2="address_alias_instantiation"

    yaml_content=$(cat "$yaml_file")
    variable_value=$(echo "$yaml_content" | yq eval ".$key_1" - | yq eval ".$key_2" - | yq eval ".$mod_name" -)

    echo "$variable_value"
}

with_prefix_to_pascal() {
    # Create an indexed array to store the mappings
    declare -a mappings=("nft_protocol" "ob_launchpad" "liquidity_layer" "liquidity_layer_v1" "ob_allowlist" "ob_authlist" "ob_kiosk" "ob_permissions" "ob_pseudorandom" "ob_request" "ob_utils" "originmate" "sui")
    declare -a variables=("NftProtocol" "Launchpad" "LiquidityLayer" "LiquidityLayerV1" "Allowlist" "Authlist" "Kiosk" "Permissions" "Pseudorandom" "Request" "Utils" "Originmate" "Sui")

    # Find the index of the provided string
    index=-1
    for i in "${!mappings[@]}"; do
        if [[ "${mappings[i]}" == "$1" ]]; then
            index=$i
            break
        fi
    done

    # Check if the provided string is recognized
    if [[ $index -eq -1 ]]; then
        echo "Unrecognized string: $1" >&2
        exit 1
    fi


    # Access the mapped value
    echo "${variables[index]}"
}

# Maps folder names to actual package_names
remove_prefix() {
    # Create an indexed array to store the mappings
    declare -a mappings=("nft_protocol" "ob_launchpad" "liquidity_layer" "liquidity_layer_v1" "ob_allowlist" "ob_authlist" "ob_kiosk" "ob_permissions" "ob_pseudorandom" "ob_request" "ob_utils" "originmate" "sui")
    declare -a variables=("nft_protocol" "launchpad" "liquidity_layer" "liquidity_layer_v1" "allowlist" "authlist" "kiosk" "permissions" "pseudorandom" "request" "utils" "originmate" "sui")

    # Find the index of the provided string
    index=-1
    for i in "${!mappings[@]}"; do
        if [[ "${mappings[i]}" == "$1" ]]; then
            index=$i
            break
        fi
    done

    # Check if the provided string is recognized
    if [[ $index -eq -1 ]]; then
        echo "Unrecognized string: $1" >&2
        exit 1
    fi


    # Access the mapped value
    echo "${variables[index]}"
}
