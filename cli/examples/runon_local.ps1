Import-Module $PSScriptRoot\..\docker-seed.psm1 -force

docker-seed -db -on localhost -e dockerize --help
docker-seed -db -on localhost -e ansible-playbook --version
