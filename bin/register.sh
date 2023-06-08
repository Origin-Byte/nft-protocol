#!/bin/bash

#
# Generates the entry used to register a package version in the OriginByte Package Registry
#

# Get the directory path of the current script
script_dir=$(dirname "$0")

# Source the other script using a relative path
source "$script_dir/mappings.sh"

register() {
    # To avoid silent errors
    set -e

    package_snake=$1 # nft_protocol
    git="https://github.com/${2}.git"
    rev=$3
    # NOTE: Contract folder only works for this repository
    source_folder="${4}/contracts"
    registry_path="${6}"

    if [ "$5" = "remote" ]; then
        stoml="./stoml"
    else
        stoml="stoml"
    fi

    package_path="${source_folder}/${package_snake}/Move.toml"
    package_pascal=$(${stoml} ${package_path} package.name) # NftProtocol
    version=$(${stoml} ${package_path} package.version)
    publishedAt=$(${stoml} ${package_path} package.published-at)
    package_prefix=$(add_prefix ${package_snake})
    objectId=$(${stoml} ${package_path} addresses.${package_prefix})

    deps_lowercase=$(${stoml} ${package_path} dependencies)
    dependencies_obj="{}"

    for DEP_LOWERCASE in ${deps_lowercase}
    do
        entries=$(${stoml} ${package_path} dependencies.${DEP_LOWERCASE})

        dep_snake=$(lowercase_to_snake_case ${DEP_LOWERCASE})
        dep_name_with_prefix=$(add_prefix ${dep_snake})
        dep_name=$(lowercase_to_pascal ${DEP_LOWERCASE})
        obj_id="0x"$(parse_build_yaml ${package_snake} ${package_pascal} ${dep_name_with_prefix})

        # Check if the variable contains the element "local"
        if [[ "${entries[*]}" == *"local"* ]]; then

            dep_git=$git
            # NOTE: Contract folder only works for this repository
            dep_subdir="contracts/${dep_snake}"
            rev_git=$rev

        else

            dep_git=$(${stoml} ${package_path} dependencies.${DEP_LOWERCASE}.git)
            rev_git=$(${stoml} ${package_path} dependencies.${DEP_LOWERCASE}.rev)
            dep_subdir=$(${stoml} ${package_path} dependencies.${DEP_LOWERCASE}.subdir)
        fi

        dependency_obj="{ \
            \"${dep_name}\": { \
                \"path\": { \
                    \"git\": \"${dep_git}\", \
                    \"subdir\": \"${dep_subdir}\", \
                    \"rev\": \"${rev_git}\" \
                }, \
                \"objectId\": \"${obj_id}\" \
            } \
        }"

        dependencies_obj=$(jq --argjson val "$dependency_obj" --arg key "$dep_name" '.[$key] += $val' <<< "$dependencies_obj")

    done

    # Create JSON object

    # TODO: objectId should not be publishedAt
    output="{ \
        \"$version\": { \
            \"package\": {
                \"name\": \"$package_pascal\", \
                \"version\": \"$version\", \
                \"publishedAt\": \"$publishedAt\" \
            }, \
            \"contractRef\": {
                \"path\": {
                    \"git\": \"$git\", \
                    \"subdir\": \"contracts/$package_snake\", \
                    \"rev\": \"$rev\" \
                }, \
                \"objectId\": \"$objectId\" \
            }, \
            \"dependencies\": ${dependencies_obj} \
        } \
    }"

    registry=$(jq '.' $registry_path)

    pkg_versions=$(jq --arg name "$package_pascal" '.[$name]' <<< "$registry")
    has_version=$(jq --arg version "$version" 'has($version)' <<< "$pkg_versions")

    if [ "$has_version" = true ]; then
        echo "Version $version already exists"
        exit 1
    fi

    registry=$(jq --argjson val "$output" --arg key "$package_pascal" '.[$key] += $val' <<< "$registry")

    echo "$registry" | jq '.' > "$registry_path"

    echo "Added $package_pascal $version to the local registry"
}
