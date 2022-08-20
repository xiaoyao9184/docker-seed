Import-Module $PSScriptRoot\..\..\docker-seed\docker-seed.psd1 -force

$script_dir = Split-Path -parent $MyInvocation.MyCommand.Definition

seed-docker -on ub.lan -e dockerize -ws $script_dir/../ws -wait https://github.com/ ls -l $script_dir/../ws/l1
