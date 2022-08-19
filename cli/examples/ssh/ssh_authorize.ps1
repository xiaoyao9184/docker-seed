Import-Module $PSScriptRoot\..\..\docker-seed.psd1 -force

seed-ssh -db -authorize root@ub.lan
