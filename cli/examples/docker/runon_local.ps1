Import-Module $PSScriptRoot\..\..\docker-seed\docker-seed.psd1 -force

seed-docker -db -on localhost -e dockerize --help
seed-docker -db -on localhost -e ansible-playbook --version
