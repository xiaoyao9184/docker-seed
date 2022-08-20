Import-Module $PSScriptRoot\..\..\docker-seed\docker-seed.psd1 -force

seed-ssh -db -authorize root@ub.lan
