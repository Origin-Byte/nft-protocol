import os

def generate_contracts_list(file_path):
    package_name = None
    published_at = None
    contracts_list = []

    with open(file_path, 'r') as file:
        lines = file.readlines()

    for line in lines:
        if line.strip().startswith('[package]'):
            package_section = True
        elif package_section and 'name' in line:
            package_name = line.split('=')[1].strip().strip('"')
        elif package_section and 'published-at' in line:
            published_at = line.split('=')[1].strip().strip('"')
            contracts_list.append((package_name, published_at))
            package_section = False

    return contracts_list

def update_readme_with_contracts(contracts):
    readme_path = 'README.md'
    updated_lines = []
    with open(readme_path, 'r') as file:
        lines = file.readlines()

    contracts_section = False
    in_contracts_list = False  # Flag to track whether we're adding contracts
    for line in lines:
        if line.strip() == '## Contracts':
            contracts_section = True
            in_contracts_list = True  # Start adding contracts
            updated_lines.append(line)
            updated_lines.append('\n- Protocol contracts:\n')
            for package_name, published_at in contracts:
                updated_lines.append(f'  - [{package_name}](https://explorer.sui.io/object/{published_at})\n')
            updated_lines.append('\n')  # Ensure an empty line after the list
            continue
        if contracts_section and line.strip().startswith('##'):
            contracts_section = False
            if in_contracts_list:
                in_contracts_list = False  # Finished adding contracts, add an extra newline for spacing
                updated_lines.append('\n')  # Add an extra newline before the next section header
        if not contracts_section or not in_contracts_list:
            updated_lines.append(line)

    with open(readme_path, 'w') as file:
        file.writelines(updated_lines)

contracts_files = [
    'contracts/pseudorandom/Move.toml',
    'contracts/utils/Move.toml',
    'contracts/permissions/Move.toml',
    'contracts/request/Move.toml',
    'contracts/allowlist/Move.toml',
    'contracts/authlist/Move.toml',
    'contracts/critbit/Move.toml',
    'contracts/originmate/Move.toml',
    'contracts/kiosk/Move.toml',
    'contracts/nft_protocol/Move.toml',
    'contracts/liquidity_layer_v1/Move.toml',
    'contracts/launchpad/Move.toml',
]

all_contracts = []
for file_path in contracts_files:
    all_contracts.extend(generate_contracts_list(file_path))

update_readme_with_contracts(all_contracts)
