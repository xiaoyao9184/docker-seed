Import-Module $PSScriptRoot\..\..\docker-seed\docker-seed.psd1 -force

seed-ssh -db -export xy@ub.lan -opt "-p 22"