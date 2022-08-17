Import-Module $PSScriptRoot\..\docker-seed.psm1 -force

docker-seed -on ub.lan -e dockerize --help
docker-seed -on ub.lan -e ansible-playbook --help

docker-seed -on ub.lan -img xiaoyao9184/docker-seed-dockerize:latest -e bash "-c hostname"
docker-seed -on ub.lan -img xiaoyao9184/docker-seed-ansible:latest -e ansible-playbook --version
