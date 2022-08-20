Import-Module $PSScriptRoot\..\..\docker-seed\docker-seed.psd1 -force

$script_dir = Split-Path -parent $MyInvocation.MyCommand.Definition

seed-docker -db ansible-playbook `
    --inventory $script_dir\..\ws\ansible\inventory-local.yml `
    $script_dir\..\ws\docker\portainer-agent-global\ansible-playbook.deploy.yml

seed-docker -db ansible-playbook `
    --inventory $script_dir\..\ws\ansible\inventory-remote.yml `
    $script_dir\..\ws\docker\portainer-agent-global\ansible-playbook.deploy.yml

seed-docker -db -on ub.lan ansible-playbook `
    --inventory $script_dir\..\ws\ansible\inventory-local.yml `
    $script_dir\..\ws\docker\portainer-agent-global\ansible-playbook.deploy.yml
