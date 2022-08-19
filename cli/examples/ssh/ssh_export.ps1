Import-Module $PSScriptRoot\..\..\docker-seed.psd1 -force

seed-ssh -db -export root@ub.lan
