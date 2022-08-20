Import-Module $PSScriptRoot\..\..\docker-seed\docker-seed.psd1 -force

seed-ssh -db -export root@ub.lan
