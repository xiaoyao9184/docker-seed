
function Test-RunOnLocal {
    param (
        [Parameter(Mandatory = $true,Position = 0)]
        [string] $machine
    )
    $local_flags = @('local','localhost')
    return $local_flags.Contains($machine)
}

function Get-DockerRunCommand {
    param (
        [Parameter(Mandatory = $true,Position = 0)]
        [PSCustomObject] $docker
    )
    Process {
        $docker_command = New-Object System.Collections.ArrayList
        # https://stackoverflow.com/a/22682725
        $docker_command.Add("docker run") | Out-Null

        $docker_command.Add("--privileged") | Out-Null
        $docker_command.Add("--user root") | Out-Null
        $docker_command.Add("--label com.docker.stack.namespace=seed") | Out-Null
        
        if ($docker.env) {
            $docker.env | ForEach-Object {
                $docker_command.Add("-e '$($_.name)=$($_.value)'") | Out-Null
            }
        }
        if ($docker.volume) {
            $docker.volume | ForEach-Object {
                $docker_command.Add("-v '$($_.source):$($_.target)$($_.read_only ? ':ro' : '')'") | Out-Null
            }
        }
        if ($docker.detach) {
            $docker_command.Add("--detach") | Out-Null
        }
        if ($docker.interactive) {
            $docker_command.Add("--interactive") | Out-Null
        }
        if ($docker.tty) {
            $docker_command.Add("--tty") | Out-Null
        }
        if ($docker.rm) {
            $docker_command.Add("--rm") | Out-Null
        }

        $docker_command.Add("--name $($docker.name)") | Out-Null
        $docker_command.Add("--entrypoint $($docker.entrypoint)") | Out-Null
        $docker_command.Add("$($docker.image)") | Out-Null
        $docker_command.Add("$($docker.command)") | Out-Null

        return $docker_command -join ' '
    }
}

function Start-SeedDocker() {
    param (
        [Parameter(Mandatory = $true,Position = 0)]
        [string] $ssh
        ,
        [Parameter(Mandatory = $true,Position = 1)]
        [bool] $background
        ,
        [Parameter(Mandatory = $true,Position = 2)]
        [PSCustomObject] $seed
    )
    
    Write-Verbose ($PSBoundParameters | Format-Table | Out-String)

    $docker = $seed.docker
    $docker.env = New-Object System.Collections.ArrayList
    $docker.volume = New-Object System.Collections.ArrayList

    
    $docker.env.Add(@{
        name = 'SEED_NAME'
        value = $docker.name
    }) | Out-Null
    $docker.env.Add(@{
        name = 'SEED_ENTRYPOINT'
        value = $docker.entrypoint
    }) | Out-Null
    $docker.env.Add(@{
        name = 'SEED_IMAGE'
        value = $docker.image
    }) | Out-Null
    $docker.env.Add(@{
        name = 'SEED_COMMAND'
        value = $docker.command
    }) | Out-Null

    $docker.volume.Add(@{
        source = '/etc/localtime'
        target = '/etc/localtime'
        read_only = $true
    }) | Out-Null

    $docker.volume.Add(@{
        source = '/var/run/docker.sock'
        target = '/var/run/docker.sock'
    }) | Out-Null

    if ($seed.workspace.enable) {
        $docker.env.Add(@{
            name = 'SEED_WORKSPACE'
            value = $seed.workspace.name
        }) | Out-Null
        
        $docker.volume.Add(@{
            source = $seed.workspace.name
            target = '/workspace'
        }) | Out-Null
    }
    if ($seed.key.enable) {
        $docker.env.Add(@{
            name = 'SEED_KEY'
            value = $seed.key.name
        }) | Out-Null
        # key file bind
        # key maybe from command
        # /root/.ssh/ key for docker-seed-remote, so bind to /key/.ssh/id_rsa
        # docker-seed-remote use ansible copy to /seed/key/{{ key.name }}/id_rsa path
        $docker.volume.Add(@{
            source = $seed.key.path
            target = '/key/.ssh/id_rsa'
        }) | Out-Null
    }

    $local = Test-RunOnLocal($ssh)
    if($local){
        if ($seed.key.enable) {
            # for command not specify key
            # key file bind to /root/./ssh/id_rsa path
            $docker.volume.Add(@{
                source = $seed.key.path
                target = '/root/.ssh/id_rsa'
            }) | Out-Null
        } else {
            # key path bind to /root/./ssh path
            $_ssh_path = Resolve-Path -Path "$env:USERPROFILE/.ssh/"
            $docker.volume.Add(@{
                source = $_ssh_path
                target = '/root/.ssh'
            }) | Out-Null
        }

        if($background){
            $docker.detach = $true
        } else {
            $docker.interactive = $true
            $docker.tty = $true
        }
    } else {
        # key path bind to /root/.ssh path
        $_ssh_path = Resolve-Path -Path "$env:USERPROFILE/.ssh/"
        $docker.volume.Add(@{
            source = $_ssh_path
            target = '/root/.ssh'
        }) | Out-Null

        # remote background will just for remote, local will auto remove
        $docker.rm = $true
        $docker.interactive = $true
        $docker.tty = $true
        if ($background) {
            $docker.env.Add(@{
                name = 'SEED_DETACH'
                value = 'true'
            }) | Out-Null
            $docker.env.Add(@{
                name = 'SEED_INTERACTIVE'
                value = 'false'
            }) | Out-Null
            $docker.env.Add(@{
                name = 'SEED_TTY'
                value = 'false'
            }) | Out-Null
        } else {
            $docker.env.Add(@{
                name = 'SEED_DETACH'
                value = 'false'
            }) | Out-Null
            $docker.env.Add(@{
                name = 'SEED_INTERACTIVE'
                value = 'true'
            }) | Out-Null
            $docker.env.Add(@{
                name = 'SEED_TTY'
                value = 'true'
            }) | Out-Null
        }

        $_playbook_file = Resolve-Path -Path "${script_dir}/docker-seed.yml"
        $docker.volume.Add(@{
            source = $_playbook_file
            target = '/docker-seed.yml'
        }) | Out-Null

        # remote will replace 'image' 'entrypoint' 'command'
        $docker.entrypoint = 'ansible-playbook'
        $docker.image = $remote_seed_image
        
        if ($PSBoundParameters.Verbose.IsPresent) {
            $_verbose = "-vvvv"
        } elseif ($PSBoundParameters.Debug.IsPresent) {
            $_verbose = "-v"
        } else {
            $_verbose = ""
        }
        $user_host = $ssh -Split '@'
        if ($user_host.Count -eq 2) {
            $_remote_user = $user_host[0]
            $_remote_host = $user_host[1]
        } else {
            $_remote_user = 'root'
            $_remote_host = $user_host[0]
        }
        $docker.command = "$_verbose --extra-vars 'user=$_remote_user host=$_remote_host' /docker-seed.yml"
    }

    $parameters = @{
        Debug = $PSBoundParameters.Debug.IsPresent ? $true : $false
        Verbose = $PSBoundParameters.Verbose.IsPresent ? $true : $false
        docker = $docker
    }
    $dock_cmd = Get-DockerRunCommand @parameters

    Write-Debug $dock_cmd

    Invoke-Expression -Command $dock_cmd
}

function Convert-ImageName {
    param (
        [Parameter(Mandatory = $true,Position = 0)]
        [string] $entrypoint
        ,
        [Parameter(Mandatory = $true,Position = 1,ValueFromRemainingArguments = $true)]
        [PSCustomObject[]] $alias
    )
    
    $_img = $alias | Where-Object {
        $_.ContainsKey($entrypoint)
    } | ForEach-Object { 
        $_[$entrypoint]
    } | Select-Object -Last 1

    $_rep_tag = $_img -Split ':'
    if ($_rep_tag.Count -eq 2) {
        $_rep = $_rep_tag[0]
        $_tag = $_rep_tag[1]
    } else {
        $_rep = $_rep_tag[0]
        $_tag = 'latest'
    }

    if ($_rep) {
        return "${_rep}:${_tag}"
    } else {
        Write-Error -Message "Use the '-Image' parameter to force the use of the specified image"
        Write-Error -Message ($entrypoint | Format-Table | Out-String)
        throw "cant find image in 'entrypoint' parameter."
    }
}

function Convert-CommandPath {
    param (
        [Parameter(Mandatory = $true)]
        [string[]] $Command
        ,
        [Parameter()]
        [string] $Workspace
        ,
        [Parameter()]
        [string] $Key
        
    )
    # $path_for_bind = New-Object System.Collections.ArrayList

    $result = $Command | ForEach-Object {
        $ex = Test-Path $_
        if ($ex) {
            $path_src = Resolve-Path $_

            # is in workspace
            $IsWorkspace = $Workspace -and $path_src.Path.StartsWith($Workspace)
            if ($IsWorkspace) {
                $path = $path_src.Path.Substring($Workspace.Length)
                return "\workspace$path" -replace '\\','/'
            }
            # is Key, but not in workspace
            $IsKey = $Key -eq $path_src.Path
            if ($IsKey) {
                return "/root/.ssh/id_rsa"
            }
            
            # if ($IsWindows) {
            #     $path_dest = $path_src -replace '\\','/'
            #     # WINDOWS convert to /mnt/c/....
            #     $path_dest = Invoke-Expression -Command "wsl wslpath $path_dest"
            # } else {
            #     $path_dest = $path_src
            # }
            # $path_for_bind.Add(@{
            #     src = $path_src
            #     dest = $path_dest
            # }) | Out-Null
            # return $path_dest
            Write-Error -Message "Detect file not in 'Workspace' so will not exist in the docker-seed container"
            Write-Error -Message ($path_src | Format-Table | Out-String)
            throw "file out of workspace."
        } else {
            return $_
        }
    }
    return $result
}

function Convert-KeyPath {
    param (
        [Parameter(Mandatory = $true,Position = 0)]
        [string] $key
    )
    $key_file = Test-Path "$key"
    if($key_file) {
        return Resolve-Path -Path $Key
    }
    $key_file = Test-Path "$env:USERPROFILE/.ssh/$key/id_rsa"
    if($key_file) {
        return $key
    }
    return $null
}

function Convert-WorkspaceVolume {
    param (
        [Parameter(Mandatory = $true,Position = 0)]
        [string] $path
        ,
        [Parameter(Mandatory = $false,Position = 1)]
        [string] $name        
    )
    if (!$name) {
        $name = Split-Path -Leaf $path
    }
    $r = docker volume create --name $name `
            --opt type=none `
            --opt device=$path `
            --opt o=bind
    
    Write-Debug "Init $name workspace"

    return $r;
}

function Read-WorkspaceParam {
    param (
        [Parameter(Mandatory = $true,Position = 0)]
        [string] $Workspace
    )
    $ws_meta_path = Join-Path -Path $Workspace -ChildPath ".seed"
    $ws_meta_file = Join-Path -Path $ws_meta_path -ChildPath "seed.json"

    $ex = Test-Path -Path $ws_meta_file
    if ($ex) {
        return Get-Content $ws_meta_file | ConvertFrom-Json
    }
}

function Get-WorkspaceByPath {
    param (
        [Parameter(Mandatory = $true,Position = 0)]
        [string] $Path
    )
    $seed_path = Join-Path -Path $Path -ChildPath ".seed"
    $seed_include = Test-Path -Path $seed_path
    if($seed_include) {
        return $Path
    } else {
        $parent_path = Split-Path -Path $Path -Parent
        if($parent_path) {
            return Get-WorkspaceByPath -Path $parent_path
        } else {
            return $null
        }
    }
}

function Get-WorkspaceByCommand {
    param (
        [Parameter(Mandatory = $true,Position = 0)]
        [string[]] $Command
    )
    Write-Debug -Message "find workspce in:"
    Write-Debug -Message ($Command | Format-Table | Out-String)
    
    # https://stackoverflow.com/questions/31343234/ensure-pipeline-always-results-in-array-without-using
    [Array]$ws_list = $Command | Where-Object {
        Test-Path $_
    } | ForEach-Object {
        $path = Resolve-Path $_
        return Get-WorkspaceByPath $path
    } | Where-Object { $_ } | Select-Object -Unique

    Write-Debug ($ws_list | Format-Table | Out-String)
    if ($null -eq $ws_list -or $ws_list.Length -eq 0) {
        Write-Warning -Message "No workspace found, workspace will not be used."
    } elseif ($ws_list.Length -gt 1) {
        Write-Error -Message "Use the '-Workspace' parameter to force the use of the specified workspace"
        Write-Error -Message ($ws_list | Format-Table | Out-String)
        throw "find multiple workspaces in command parameter."
    } else {
        return $ws_list
    }
}

function Get-KeyName {
    param (
        [Parameter(Mandatory = $true,Position = 0)]
        [string] $path
        ,
        [Parameter(Mandatory = $false,Position = 1)]
        [string] $name
    )
    $key_file = Test-Path "$env:USERPROFILE/.ssh/$name/id_rsa"
    if ($key_file) {
        return $name
    }
    $key_hash = Get-FileHash -Path $path -Algorithm MD5
    return $key_hash.Hash
}

function Get-KeyByCommand {
    param (
        [Parameter(Mandatory = $true,Position = 0)]
        [string[]] $Command
    )
    Write-Debug -Message "find key in:"
    Write-Debug -Message ($Command | Format-Table | Out-String)

    [Array]$key_list = $Command | Where-Object {
        Test-Path $_ -PathType Leaf
    } | ForEach-Object {
        $path = Resolve-Path $_
        $key_info = Invoke-Expression -Command "ssh-keygen -l -f $path"
        if ($key_info) {
            return $path
        }
    } | Where-Object { $_ } | Select-Object -Unique
    
    Write-Debug ($key_list | Format-Table | Out-String)
    if ($null -eq $key_list -or $key_list.Length -eq 0) {
        Write-Warning -Message "No key found, key will not be used."
    } elseif ($key_list.Length -gt 1) {
        Write-Error -Message "Use the '-Key' parameter to force the use of the specified key"
        Write-Error -Message ($key_list | Format-Table | Out-String)
        throw "find multiple keys in command parameter."
    } else {
        return $key_list
    }
}

function Merge-SeedParam {
    param (
        [Parameter(Mandatory = $false,Position = 0)]
        [PSCustomObject] $seed
        ,
        [Parameter(Mandatory = $false,Position = 1)]
        [hashtable] $target
    )
    if (! $target) {
        $target = @{ 
            docker = @{
                name = $null
                image = $null
                entrypoint = $null
                command = $null
            }
            workspace = @{
                enable = $false
                name = $null
                path = $null
            }
            key = @{
                enable = $false
                path = $null
            }
            entrypoint_image_alias = @{}
        }
    }
    if ($seed) {
        ForEach ($kv in $seed.psobject.properties) {
            ForEach ($kv2 in $kv.Value.psobject.properties) {
                $target[$kv.Name][$kv2.Name] = $kv2.Value 
            }
        }
    }
    return $target
}

function Select-DockerSeed {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,Position = 0)]
        [Alias("e")]
        [ArgumentCompleter({ EntrypointArgumentCompleter @args })]
        [string] $Entrypoint
        ,
        # https://stackoverflow.com/questions/62861665/powershell-pass-all-parameters-received-in-function-and-handle-parameters-with
        [Parameter(Mandatory = $true,Position = 1, ValueFromRemainingArguments = $true)]
        [Alias("c","cmd")]
        [string[]] $Command
        ,
        [Parameter()]
        [Alias("i","img")]
        [ArgumentCompleter({ ImageArgumentCompleter @args })]
        [string] $Image
        ,
        [Parameter()]
        [Alias("w","ws")]
        [ArgumentCompleter({ WorkspaceArgumentCompleter @args })]
        [string] $Workspace
        ,
        [Parameter()]
        [Alias("k","id")]
        [ArgumentCompleter({ KeyArgumentCompleter @args })]
        [string] $Key
        ,
        [Parameter()]
        [Alias("o","on")]
        [ArgumentCompletions('localhost', '192.168.x.x')]
        [string] $RunOn
        ,
        [Parameter()]
        [Alias("b","bg","background")]
        [switch] $RunBackground
        ,
        [Parameter()]
        [Alias("n")]
        [string] $Name
    )
    Begin{}
    Process{
        # Write-Debug (@Args | Format-Table | Out-String)
        Write-Verbose ($PSBoundParameters | Format-Table | Out-String)

        $Seed = Merge-SeedParam

        if (! $Workspace) {
            Write-Debug -Message "try to find workspace by use -Command param"
            $Workspace = Get-WorkspaceByCommand $Command
        }

        if ($Workspace -and $Workspace -ne "NONE") {
            $Workspace = Resolve-Path -Path $Workspace
            
            Write-Debug -Message "try to read seed param from workspace"
            $WorkspaceSeed = Read-WorkspaceParam -Workspace $Workspace
            $Seed = Merge-SeedParam -seed $WorkspaceSeed -target $Seed

            $Seed.workspace.enable = $true
            $Seed.workspace.path = $Workspace
            $Seed.workspace.name = Convert-WorkspaceVolume -path $Workspace -name $Seed.workspace.name
        }

        if (! $Key) {
            Write-Debug -Message "try to find key by use -Command param"
            $Key = Get-KeyByCommand $Command
        }
        if($Key -and $Key -ne "NONE"){
            $Seed.key.path = Convert-KeyPath -key $Key
            $Seed.key.enable = Test-Path -Path $Seed.key.path
            $Seed.key.name = Get-KeyName -path $Seed.key.path -name $Key
        }

        Write-Debug -Message "try to convert command path to relative workspace path"
        $Command = Convert-CommandPath -Command $Command -Workspace $Workspace -Key $Key

        if (! $Image) {
            $Image = Convert-ImageName -entrypoint $Entrypoint `
                -alias $entrypoint_image_alias,$Seed.entrypoint_image_alias
        }
        if ($Image) {
            $Seed.docker.image = $Image
        }

        if(! $RunOn){
            $RunOn = "local"
        }
        if (! $Name) {
            $id = New-Guid
            $Name = "seed-$id"
        }
        
        
        $Seed.docker.name = $Name
        $Seed.docker.entrypoint = $Entrypoint
        $Seed.docker.command = $Command

        $parameters = @{
            Debug = $PSBoundParameters.Debug.IsPresent ? $true : $false
            Verbose = $PSBoundParameters.Verbose.IsPresent ? $true : $false
            ssh = $RunOn
            background = $RunBackground
            seed = $Seed
        }
        Start-SeedDocker @parameters
    }
    End{}
}


function KeyArgumentCompleter {
    param (
        $commandName,
        $parameterName,
        $wordToComplete,
        $commandAst,
        $fakeBoundParameters
    )

    return Get-ChildItem -Path "$env:USERPROFILE/.ssh/" -Directory | Where-Object {
        Test-Path "$_/id_rsa"
    } | ForEach-Object { $_.Name }
}

function WorkspaceArgumentCompleter {
    param (
        $commandName,
        $parameterName,
        $wordToComplete,
        $commandAst,
        $fakeBoundParameters
    )

    $cd = Get-Location
    [Array]$WorkspaceList = Get-Workspace $cd
    return $WorkspaceList
}

function ImageArgumentCompleter {
    param (
        $commandName,
        $parameterName,
        $wordToComplete,
        $commandAst,
        $fakeBoundParameters
    )

    if ($fakeBoundParameters.ContainsKey('Entrypoint')) {
        $entrypoint = $fakeBoundParameters.Entrypoint
        
        if ($entrypoint_image_alias.ContainsKey($entrypoint)) {
            $find_images = $entrypoint_image_alias[$entrypoint]
        }
    } else {
        $find_images = $entrypoint_image_alias.values
    }

    $filter = $find_images | ForEach-Object {
        "--filter '${_}:*'"
    } -join ' '

    $docker_images = Invoke-Expression -ErrorAction Ignore `
        -Command "docker image ls $filter --format '{{.Repository}}:{{.Tag}}'"

    return $docker_images
}

function EntrypointArgumentCompleter {
    param (
        $commandName,
        $parameterName,
        $wordToComplete,
        $commandAst,
        $fakeBoundParameters
    )
    
    if ($fakeBoundParameters.ContainsKey('Image')) {
        $repository_tag = $fakeBoundParameters.Image -Split ':'
        
        $entrypoint_image_alias.Keys | Where-Object {
            $entrypoint_image_alias[$_] -eq $repository_tag[0]
        }
    } else {
        return $entrypoint_image_alias.keys
    }
}

$script_dir = Split-Path -parent $MyInvocation.MyCommand.Definition
$remote_seed_image = "xiaoyao9184/docker-seed-ansible:latest"
$entrypoint_image_alias = @{
    dockerize = 'xiaoyao9184/docker-seed-dockerize'
    wait4x = 'xiaoyao9184/docker-seed-wait4x'
    ansible = 'xiaoyao9184/docker-seed-ansible'
    'ansible-playbook' = 'xiaoyao9184/docker-seed-ansible'
}
Set-Alias -Name "docker-seed" -Value Select-DockerSeed
Export-ModuleMember -Alias docker-seed
Export-ModuleMember -Function Select-DockerSeed
