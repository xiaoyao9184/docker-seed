Import-Module $PSScriptRoot\..\..\docker-seed.psd1 -force

seed-docker -on ub.lan -e dockerize --help
seed-docker -on ub.lan -e ansible-playbook --help

seed-docker -on ub.lan -img xiaoyao9184/docker-seed-dockerize:latest -e bash "-c hostname"
seed-docker -on ub.lan -img xiaoyao9184/docker-seed-ansible:latest -e ansible-playbook --version
