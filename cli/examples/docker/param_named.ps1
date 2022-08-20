Import-Module $PSScriptRoot\..\..\docker-seed\docker-seed.psd1 -force

seed-docker -db -e dockerize --version
seed-docker -db -ea Continue -e none --version