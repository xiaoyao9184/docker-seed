
function Add-Workspace($path, $name) {
    
    New-Item -Path $path -ItemType Directory -Force

    New-Item -Path "$path/.seed" -ItemType Directory -Force

    if (!$name) {
        $name = "null"
    } else {
        $name = "`"$name`""
    }

    $text=@"
{
  "workspace": {
    "name": $name
  }
}
"@
    # deprecated not recommended use
    Add-Content -Path "$path/.seed/seed.json" "$text"
    # recommended this
    Add-Content -Path "$path/seed.json" "$text"

    Write-Output ""
    Write-Output "add done"
}

function Invoke-SeedWorkspace() {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [Alias("p")]
        [string] $Path
        ,
        [Parameter(Mandatory = $false)]
        [Alias("n")]
        [string] $Name
    )

    Write-Verbose ($PSBoundParameters | Format-Table | Out-String)
    
    $ws_file = Test-Path "$Path"
    if ($ws_file) {
        Write-Error -Message "Path exists, cannot create new workspace"
        throw "workspace path conflict."
    }

    Add-Workspace -path $Path -name $Name

}

Set-Alias -Name "seed-ws" -Value Invoke-SeedWorkspace
