Import-Module $PSScriptRoot\..\docker-seed.psm1 -force

docker-seed -db -e dockerize --version
docker-seed -db -ea Continue -e none --version