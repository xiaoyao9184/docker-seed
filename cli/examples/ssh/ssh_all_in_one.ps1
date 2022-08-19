Import-Module $PSScriptRoot\..\..\docker-seed.psd1 -force

seed-ssh -db -export root@ub.lan -authorize root@ub.lan,root@ub

seed-ssh -db -root xy@ub.lan -export root@ub.lan -authorize root@ub.lan,root@ub
