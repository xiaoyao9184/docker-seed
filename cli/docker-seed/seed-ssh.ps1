
function Add-Config($ssh_host,$ssh_user,$ssh_identity) {

    Write-Output ""
    Write-Output "add config identity ${ssh_identity} for target '${ssh_user}@${ssh_host}'"

    $text=@"

Host ${ssh_host}
  HostName ${ssh_host}
  IdentityFile ${ssh_identity}
  User ${ssh_user}
"@

    Add-Content -Path "$env:USERPROFILE/.ssh/config" "$text"

}

function Approve-Item($ssh_host,$ssh_user,$ssh_key,$ssh_options) {
    
    Write-Output ""
    Write-Output "authorize ssh public key ${ssh_key} for target '${ssh_user}@${ssh_host}'"
    
    Get-Content "$env:USERPROFILE/.ssh/${ssh_key}/id_rsa.pub" | 
        ssh "$ssh_options" "${ssh_user}@${ssh_host}" "mkdir -p ~/.ssh/ && cat >> ~/.ssh/authorized_keys"

}

Function Approve-Key($ssh_destination,$ssh_key,$ssh_options) {
    
    $_ssh_user = ''
    $_ssh_host = ''
    $_ssh_key = ''

    if ($ssh_key) {
        $_ssh_user_host = $ssh_key -Split '@'
    } else {
        $_ssh_list = $ssh_destination -split ';'
        $_ssh_user_host = $_ssh_list[0] -Split '@'
    }
    if ($_ssh_user_host.Count -eq 2) {
        $_ssh_key = $_ssh_user_host[1]
    } else {
        $_ssh_key = $_ssh_user_host[0]
    }
    $_key_ex = Test-Path -Path "$env:USERPROFILE/.ssh/${_ssh_key}/id_rsa.pub"        
    if ($_key_ex) {
        $ssh_destination -split ';' | ForEach-Object {

            $_ssh_user_host = $_ -Split '@'
            if ($_ssh_user_host.Count -eq 2) {
                $_ssh_user = $_ssh_user_host[0]
                $_ssh_host = $_ssh_user_host[1]
            } else {
                $_ssh_host = $_ssh_user_host[0]
            }
            Approve-Item -ssh_user $_ssh_user -ssh_host $_ssh_host -ssh_key $_ssh_key -ssh_options $ssh_options
            
            $ssh_identity = "~/.ssh/${_ssh_key}/id_rsa"
            Add-Config -ssh_host $_ssh_host -ssh_user $_ssh_user -ssh_identity $ssh_identity
        
        }
    
        Write-Output ""
        Write-Output "authorize done"
    } else {
        Write-Warning "authorize public key $_ssh_key not exist skip"
        Write-Warning "make sure file exist at $env:USERPROFILE/.ssh/${_ssh_key}/id_rsa.pub"
    }
}

function Set-Mode {    
    Write-Output ""
    Write-Output "fix key permission for windows docker and wsl"

    $chmod_docker = @"
docker run 
--rm 
--tty 
--interactive 
--privileged 
--user root 
-v '$env:USERPROFILE/.ssh:/root/.ssh' 
--entrypoint bash 
xiaoyao9184/docker-seed-ansible:latest 
-c 'chmod -R 600 /root/.ssh/' 
"@ -replace "`r`n",''

    Invoke-Expression -Command "$chmod_docker"
}

function Save-Key($ssh_destination,$ssh_key,$ssh_options) {

    Write-Output ""
    Write-Output "save rsa key form '${ssh_destination}' to $env:USERPROFILE/.ssh/${ssh_key}"
    
    New-Item -Path "$env:USERPROFILE/.ssh/${ssh_key}/" -ItemType Directory -Force | Out-Null

    $key_public = ssh -t "$ssh_options" "${ssh_destination}" "cat ~/.ssh/id_rsa.pub"
    $key_public -join "`n" | Out-File "$env:USERPROFILE/.ssh/${ssh_key}/id_rsa.pub"

    $key_private = ssh -t "$ssh_options" "${ssh_destination}" "cat ~/.ssh/id_rsa"
    $key_private -join "`n" | Out-File "$env:USERPROFILE/.ssh/${ssh_key}/id_rsa"
    
}

function Add-Key($ssh_destination,$ssh_options) {

    Write-Output ""
    Write-Output "generate ssh rsa key on target '${ssh_destination}'"

    # https://serverfault.com/questions/939909/ssh-keygen-does-not-create-rsa-private-key
    ssh -t "$ssh_options" "$ssh_destination" "ssh-keygen -m PEM -t rsa -b 2048 -f ~/.ssh/id_rsa -q -P ''"

}

function Export-Key($ssh_destination,$ssh_options) {

    $_ssh_user_host = $ssh_destination -Split '@'
    if ($_ssh_user_host.Count -eq 2) {
        $_ssh_key = $_ssh_user_host[1]
    } else {
        $_ssh_key = $_ssh_user_host[0]
    }

    $_key_ex = Test-Path -Path "$env:USERPROFILE/.ssh/${_ssh_key}/id_rsa.pub"
    $_key_ex = $_key_ex -and (Test-Path -Path "$env:USERPROFILE/.ssh/${_ssh_key}/id_rsa")
    if (! $_key_ex) {
        Add-Key -ssh_destination $ssh_destination -ssh_options $ssh_options

        Save-Key -ssh_destination $ssh_destination -ssh_key $_ssh_key -ssh_options $ssh_options

        Set-Mode

        Write-Output ""
        Write-Output "export done"
    } else {
        Write-Warning "export private/public key $_ssh_key exist skip"
        Write-Warning "not need generate again. see $env:USERPROFILE/.ssh/${_ssh_key}/"
    }
}

function Reset-Password($ssh_destination,$ssh_options) {

    Write-Output ""
    Write-Output "reset 'root' password on target '${ssh_destination}'"

    ssh -t "$ssh_options" "$ssh_destination" "sudo passwd"

}

function Restart-SSH($ssh_destination,$ssh_options) {

    Write-Output ""
    Write-Output "restart ssh service on target '${ssh_destination}'"

    ssh -t "$ssh_options" "$ssh_destination" "sudo systemctl restart ssh"

}

function Edit-Config($ssh_destination,$ssh_options) {

    Write-Output ""
    Write-Output "config sshd 'PermitRootLogin yes' on target '${ssh_destination}'"

    ssh -t "$ssh_options" "$ssh_destination" "sudo sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config"

}

function Enable-Root($ssh_destination,$ssh_options) {
    
    $ssh_destination -split ';' | ForEach-Object {

        Edit-Config -ssh_destination $_ -ssh_options $ssh_options

        Restart-SSH -ssh_destination $_ -ssh_options $ssh_options

        Reset-Password -ssh_destination $_ -ssh_options $ssh_options
    }

    Write-Output ""
    Write-Output "enable done"
}

function Invoke-SeedSSH() {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [Alias("root")]
        [string[]] $PermitRoot
        ,
        [Parameter(Mandatory = $false)]
        [Alias("e")]
        [string] $Export
        ,
        [Parameter(Mandatory = $false)]
        [Alias("a")]
        [string[]] $Authorize
        ,
        [Parameter(Mandatory = $false)]
        [Alias("opt")]
        [string[]] $Options
    )

    Write-Verbose ($PSBoundParameters | Format-Table | Out-String)

    if ($PermitRoot) {
        Write-Output "enable 'root' user ssh login"
        Enable-Root -ssh_destination $PermitRoot -ssh_options ($Options -join ' ')
    }

    if ($Export) {
        Write-Output "export ssh key into user home"
        Export-Key -ssh_destination $Export -ssh_options ($Options -join ' ')
    }
    
    if ($Authorize) {
        Write-Output "authorize multiple host use ssh key"
        Approve-Key -ssh_destination $Authorize -ssh_key $Export -ssh_options ($Options -join ' ')
    }
}

Set-Alias -Name "seed-ssh" -Value Invoke-SeedSSH
