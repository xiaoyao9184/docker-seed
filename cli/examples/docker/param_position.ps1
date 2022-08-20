Import-Module $PSScriptRoot\..\..\docker-seed\docker-seed.psd1 -force

seed-docker -db dockerize --help
seed-docker -db dockerize -wait https://github.com/ echo 'all good'
