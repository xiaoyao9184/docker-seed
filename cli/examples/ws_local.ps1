Import-Module $PSScriptRoot\..\docker-seed.psm1 -force

$script_dir = Split-Path -parent $MyInvocation.MyCommand.Definition

docker-seed -db -on localhost -e dockerize -ws $script_dir/ws -wait https://github.com/ ls -l $script_dir/ws/l1
