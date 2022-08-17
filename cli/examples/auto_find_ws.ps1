Import-Module $PSScriptRoot\..\docker-seed.psm1 -force

$script_dir = Split-Path -parent $MyInvocation.MyCommand.Definition

# no workspace
docker-seed -db ansible-playbook "$script_dir"

# error workspace
docker-seed -db -ea Ignore ansible-playbook "$script_dir\ws\l1\ansible-playbook.yml" "$script_dir\ws\l1\ansible-playbook.yml"

docker-seed -db ansible-playbook "$script_dir" "$script_dir\ws\l1\ansible-playbook.yml"

docker-seed -db ansible-playbook "$script_dir\ws\l1\ansible-playbook.yml"

docker-seed -db ansible-playbook "$script_dir\ws\l1\l2\ansible-playbook.yml"