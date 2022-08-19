Import-Module $PSScriptRoot\..\..\docker-seed.psd1 -force

$script_dir = Split-Path -parent $MyInvocation.MyCommand.Definition

seed-docker -db -on localhost -e ansible-inventory -ws $script_dir/../ws --version
