#!/bin/bash

#
# Generates the entry used to register a package version in the OriginByte Package Registry
#

set -e

# jq '.NftProtocol += { "1.2.0": "yikes!" }' versions.json > versions_1.json
program=$1
git=$2
rev=$3

# TODO: This should be replaced by args
git="https://github.com/Origin-Byte/originmate.git"
rev="ae1212baf8f0837e25926d941db3d26a61c1bea2"

# Function to convert PascalCase to snake_case
pascal_to_snake() {
  echo "$1" | sed 's/\([^A-Z]\)\([A-Z]\)/\1_\2/g' | tr '[:upper:]' '[:lower:]'
}

# Define the mapping function
map_variables() {
    # Create an indexed array to store the mappings
    declare -a mappings=("nft_protocol" "launchpad" "liquidity_layer" "liquidity_layer_v1" "allowlist" "authlist" "kiosk" "permissions" "pseudorandom" "request" "utils" "originmate" "sui")
    declare -a variables=("nft_protocol" "launchpad" "liquidity_layer" "liquidity_layer_v1" "ob_allowlist" "ob_authlist" "ob_kiosk" "ob_permissions" "ob_pseudorandom" "ob_request" "ob_utils" "originmate" "sui")

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

# Define the mapping function
map_variables_2() {
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

parse_build_yaml() {
    folder_name="$1"
    pascal_name="$2"
    mod_name="$3"

    yaml_file="contracts/${folder_name}/build/${pascal_name}/BuildInfo.yaml"

    key_1="compiled_package_info"
    key_2="address_alias_instantiation"

    yaml_content=$(cat "$yaml_file")
    variable_value=$(echo "$yaml_content" | yq eval ".$key_1" - | yq eval ".$key_2" - | yq eval ".$mod_name" -)

    echo "$variable_value"
}


# git="https://github.com/Origin-Byte/nft-protocol.git",
# subdir="contracts/nft_protocol",
# rev="b3c85b735f047a17298d2640357bc75a67538890"

path="contracts/${program}/Move.toml"

name=$(stoml ${path} package.name)
version=$(stoml ${path} package.version)
publishedAt=$(stoml ${path} package.published-at)

# Variables
output_file="output.json"

# Create JSON object
package_object="{
    \"name\": \"$name\", \
    \"version\": \"$version\", \
    \"publishedAt\": \"$publishedAt\" \
}"

# Write ContractRef - This part is hardoced but it needs to be populated dynamically
path_object="{
    \"git\": \"$git\", \
    \"subdir\": \"$subdir\", \
    \"rev\": \"$rev\" \
}"

contract_ref_object="{
    \"path\": ${path_object}, \
    \"objectId\": \"$publishedAt\" \
}"

dependencies=$(stoml ${path} dependencies)
dependencies_obj="{}"

for DEPENDENCY in ${dependencies}
do
    entries=$(stoml ${path} dependencies.${DEPENDENCY})

    # Check if the variable contains the element "local"
    if [[ "${entries[*]}" == *"local"* ]]; then

    dep_git=$git
    folder_name=$(pascal_to_snake ${name})
    dep_subdir="contracts/${folder_name}"
    rev_git=$rev

else

    dep_git=$(stoml ${path} dependencies.${DEPENDENCY}.git)
    rev_git=$(stoml ${path} dependencies.${DEPENDENCY}.rev)
    dep_subdir=$(stoml ${path} dependencies.${DEPENDENCY}.subdir)
fi

    path_object="{
        \"git\": \"${dep_git}\", \
        \"subdir\": \"${dep_subdir}\", \
        \"rev\": \"${rev_git}\" \
    }"

    mod_name=$(map_variables ${program})
    obj_id=$(parse_build_yaml ${program} ${name} ${mod_name})
    dep_name=$(map_variables_2 ${DEPENDENCY})

    dependency_obj=$(jq -n --argjson path "$path_object" --arg objId "$obj_id" '{ "path": $path, "objectId": $objId }')
    dependencies_obj=$(jq --argjson val "$dependency_obj" --arg key "$dep_name" '.[$key] += $val' <<< "$dependencies_obj")

done

# Write JSON object to file using jq
json_object="{
    \"package\": ${package_object}, \
    \"contractRef\": ${contract_ref_object}, \
    \"dependencies\": ${dependencies_obj} \
}"


echo "$json_object" | jq '.' > "$output_file"

echo "JSON object written to $output_file."
