Import-Module $PSScriptRoot\..\docker-seed.psm1 -force

$script_dir = Split-Path -parent $MyInvocation.MyCommand.Definition

docker-seed -db ansible-playbook `
    --inventory $script_dir\ws\ansible\inventory-local.yml `
    $script_dir\ws\docker\portainer-agent-global\ansible-playbook.deploy.yml

docker-seed -db ansible-playbook `
    --inventory $script_dir\ws\ansible\inventory-remote.yml `
    $script_dir\ws\docker\portainer-agent-global\ansible-playbook.deploy.yml

docker-seed -db -on ub.lan ansible-playbook `
    --inventory $script_dir\ws\ansible\inventory-local.yml `
    $script_dir\ws\docker\portainer-agent-global\ansible-playbook.deploy.yml
