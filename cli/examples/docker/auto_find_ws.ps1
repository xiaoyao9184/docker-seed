Import-Module $PSScriptRoot\..\..\docker-seed\docker-seed.psd1 -force

$script_dir = Split-Path -parent $MyInvocation.MyCommand.Definition

# no workspace
seed-docker -db ansible-playbook "$script_dir"

# error workspace
seed-docker -db -ea Ignore ansible-playbook "$script_dir\..\ws\l1\ansible-playbook.yml" "$script_dir\..\ws\l1\ansible-playbook.yml"

seed-docker -db ansible-playbook "$script_dir" "$script_dir\..\ws\l1\ansible-playbook.yml"

seed-docker -db ansible-playbook "$script_dir\..\ws\l1\ansible-playbook.yml"

seed-docker -db ansible-playbook "$script_dir\..\ws\l1\l2\ansible-playbook.yml"