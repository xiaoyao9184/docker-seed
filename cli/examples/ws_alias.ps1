Import-Module $PSScriptRoot\..\docker-seed.psm1 -force

$script_dir = Split-Path -parent $MyInvocation.MyCommand.Definition

docker-seed -db -on localhost -e ansible-inventory -ws $script_dir/ws --version
