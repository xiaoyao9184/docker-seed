Import-Module $PSScriptRoot\..\docker-seed.psm1 -force

docker-seed -db dockerize --help
docker-seed -db dockerize -wait https://github.com/ echo 'all good'
