Import-Module $PSScriptRoot\..\..\docker-seed\docker-seed.psd1 -force

Remove-Item $PSScriptRoot\..\ws1 -Recurse

seed-ws -db -path $PSScriptRoot\..\ws1 -name test

Remove-Item $PSScriptRoot\..\ws1 -Recurse