Import-Module $PSScriptRoot\..\..\docker-seed\docker-seed.psd1 -force

seed-ws -db -path $PSScriptRoot\..\ws
