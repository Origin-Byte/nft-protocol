#!/bin/bash

#
# Generates the entry used to register a package version in the OriginByte Package Registry
#

# Get the directory path of the current script
script_dir=$(dirname "$0")

# Source the other script using a relative path
source "$script_dir/mappings.sh"

# To avoid silent errors
set -e


register() {
    program=$1
    git="https://github.com/${2}.git"
    rev=$3
    source_folder="${4}"
    registry_path="${6}"

    if [ "$5" = "remote" ]; then
        stoml="./stoml"
    else
        stoml="stoml"
    fi

    path="${source_folder}/${program}/Move.toml"
    name=$(${stoml} ${path} package.name)
    version=$(${stoml} ${path} package.version)
    publishedAt=$(${stoml} ${path} package.published-at)

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

    # TODO: Here it should not be publishedAt
    contract_ref_object="{
        \"path\": ${path_object}, \
        \"objectId\": \"$publishedAt\" \
    }"

    dependencies=$(${stoml} ${path} dependencies)
    dependencies_obj="{}"

    for DEPENDENCY in ${dependencies}
    do
        entries=$(${stoml} ${path} dependencies.${DEPENDENCY})

        # Check if the variable contains the element "local"
        if [[ "${entries[*]}" == *"local"* ]]; then

        dep_git=$git
        folder_name=$(pascal_to_snake ${name})
        dep_subdir="${source_folder}/${folder_name}"
        rev_git=$rev

    else

        dep_git=$(${stoml} ${path} dependencies.${DEPENDENCY}.git)
        rev_git=$(${stoml} ${path} dependencies.${DEPENDENCY}.rev)
        dep_subdir=$(${stoml} ${path} dependencies.${DEPENDENCY}.subdir)
    fi

        path_object="{
            \"git\": \"${dep_git}\", \
            \"subdir\": \"${dep_subdir}\", \
            \"rev\": \"${rev_git}\" \
        }"

        mod_name=$(add_prefix ${program})
        obj_id=$(parse_build_yaml ${program} ${name} ${mod_name})
        dep_name=$(lowercase_to_pascal ${DEPENDENCY})

        dependency_obj=$(jq -n --argjson path "$path_object" --arg objId "$obj_id" '{ "path": $path, "objectId": $objId }')
        dependencies_obj=$(jq --argjson val "$dependency_obj" --arg key "$dep_name" '.[$key] += $val' <<< "$dependencies_obj")

    done

    # Write JSON object to file using jq
    inner="{
        \"package\": ${package_object}, \
        \"contractRef\": ${contract_ref_object}, \
        \"dependencies\": ${dependencies_obj} \
    }"

    output="{
        \"$version\": ${inner} \
    }"

    registry=$(jq '.' $registry_path)

    pkg_versions=$(jq --arg name "$name" '.[$name]' <<< "$registry")
    has_version=$(jq --arg version "$version" 'has($version)' <<< "$pkg_versions")

    if [ "$has_version" = true ]; then
        echo "Version $version already exists"
        exit 1
    fi


    registry=$(jq --argjson val "$output" --arg key "$name" '.[$key] += $val' <<< "$registry")

    echo "$registry" | jq '.' > "$registry_path"

    echo "Added $name $version to the local registry"
}
