# docker-seed-cli

The `docker-seed-cli` is powershell module, 
after `Install-Module -Name docker-seed` or `Import-Module` you can use these cmdlet to run it.

| cmdlet | alias |
|:----- |:----- |
| Invoke-SeedDocker | [seed-docker](#seed-docker) |
| Invoke-SeedSSH | [seed-ssh](#seed-ssh) |




## seed-docker 


### syntax

```
Invoke-SeedDocker
    [-RunOn <String>]
    [-RunBackground <String>]
    [-Workspace <String>]
    [-Key <String>]
    [-Image <String>]
    [-Name <String>]
    [-Entrypoint] <String>
    [-Command] <String[]>

seed-docker
    [-on <String>]
    [-bg <String>]
    [-ws <String>]
    [-id <String>]
    [-img <String>]
    [-n <String>]
    [-e] <String>
    [-cmd] <String[]>
```


### description

`seed-docker` is a wrapper for `docker run` command, 
you must specify `Entrypoint` and `Command` for run,
after that `seed-docker` can guess the `Image` that needs to be run through the `Entrypoint` parameter


The following is to specify the `Entrypoint` parameter by shorthand `-e`

```powershell
seed-docker -e dockerize ...
seed-docker -e wait4x ...
seed-docker -e ansibe ...
seed-docker -e ansibe-playbook ...
```

Only these 4 `Entrypoint` can be guessed `Image`,
for other , you must to specify via `-image`, `-img` or `-i`

```powershell
seed-docker -image xiaoyao9184/docker-seed-ansible:latest ...
```

It also supports the following parameters, see [parameters](#parameters)

```powershell
seed-docker -on localhost ...
seed-docker -name seed-for-deploy-pgsql ...
seed-docker -workspace $PWD/examples/ws ...
seed-docker -key $env:USERPROFILE/.ssh/id_rsa ...
seed-docker -background ...
```

Also supports positional parameters, simplified like this

```powershell
seed-docker ansibe-playbook $PWD/examples/ws/docker/portainer-agent-global/ansible-playbook.deploy.yml
```


### parameters


#### -Entrypoint

same as `docker run` `--entrypoint`.

|  |  |
|:----- |:----- |
| Type: | String |
| Aliases: | e |
| Position:	| 1 |
| Default value: | None |
| Accept pipeline input: | False |
| Accept wildcard characters: | False |


#### -Command

same as `docker run` `command`.

|  |  |
|:----- |:----- |
| Type: | String[] |
| Aliases: | c,cmd |
| Position:	| 2 |
| Default value: | None |
| Accept pipeline input: | False |
| Accept wildcard characters: | False |


#### -RunOn

for run location, local or remote, 
local use `localhost`,
remote use host name or ip, or with user name like this `root@192.168.1.1`.

|  |  |
|:----- |:----- |
| Type: | String |
| Aliases: | o,on |
| Position:	| Named |
| Default value: | 'localhost' |
| Accept pipeline input: | False |
| Accept wildcard characters: | False |


#### -RunBackground

for background run, 
if true, will use `--detach` in `docker run`,
if not, will use `--interactive` and `--tty` in `docker run`.

|  |  |
|:----- |:----- |
| Type: | SwitchParameter |
| Aliases: | b,bg,background |
| Position:	| Named |
| Default value: | False |
| Accept pipeline input: | False |
| Accept wildcard characters: | False |


#### -Workspace

the workspace path mount in docker,
copy limited in this directory when running on a remote host,
so limit the relative directory in the file to this directory.

|  |  |
|:----- |:----- |
| Type: | String |
| Aliases: | w,ws |
| Position:	| Named |
| Default value: | None |
| Accept pipeline input: | False |
| Accept wildcard characters: | False |


#### -Key

ssh key for use, like workspace it will mount to `/root/.ssh/id_rsa` in docker.
for remote host will be copy to a temporary directory(`/seed/key`) then mount it.

|  |  |
|:----- |:----- |
| Type: | String |
| Aliases: | k,id |
| Position:	| Named |
| Default value: | None |
| Accept pipeline input: | False |
| Accept wildcard characters: | False |


#### -Image

same as `docker run` `image`.

|  |  |
|:----- |:----- |
| Type: | String |
| Aliases: | i,img |
| Position:	| Named |
| Default value: | None |
| Accept pipeline input: | False |
| Accept wildcard characters: | False |


#### -Name

same as `docker run` `name`.

|  |  |
|:----- |:----- |
| Type: | String |
| Aliases: | n |
| Position:	| Named |
| Default value: | None |
| Accept pipeline input: | False |
| Accept wildcard characters: | False |


### Run on Linux

powershell can run on linux, 
but using `seed-docker` on linux  is totally unnecessary,
because the commands used by `seed-docker` are directly available in linux.

The only difference is that `seed-docker` supports sending seed container to run on a remote docker machine.

Its implementation principle is to run a [seed-remote.yml](.seed-remote.yml) playbook through the `ansible-playbook` command.

The following bash script is the core principle, you can run it in wsl.

```bash
KEY_SRC=/root/.ssh/id_rsa \
WORKSPACE_SRC=$PWD/examples/ws \
SEED_WORKSPACE=seed-integration-test-workspace \
SEED_KEY=default \
SEED_DETACH=false \
SEED_INTERACTIVE=true \
SEED_TTY=true \
SEED_NAME=seed-$(cat /proc/sys/kernel/random/uuid) \
SEED_ENTRYPOINT=ansible-playbook \
SEED_IMAGE=xiaoyao9184/docker-seed-ansible:latest \
SEED_COMMAND=l1/ansible-playbook.yml \
ansible-playbook --extra-vars host=localhost seed-remote.yml
```

The windows pwsh equivalent to this script is as follows

```powershell
seed-docker -ws $PWD/examples/ws -key $env:USERPROFILE/.ssh/id_rsa `
    -e ansible-playbook -cmd $PWD/examples/ws/ansible-playbook.yml
```




## seed-ssh


### syntax

```
Invoke-SeedSSH
    [-PermitRoot <String[]>]
    [-Export <String>]
    [-Authorize <String[]>]
    [-Options <String>]

seed-ssh
    [-root <String[]>]
    [-e <String>]
    [-a <String[]>]
    [-opt <String>]
```


### description

`seed-ssh` is a wrapper for `ssh` command, 
usually used to set up a docker cluster for ssh key login without password,
you must specify ssh *destination* for run like `root@192.168.1.1`


Usually ubuntu cannot use root user for ssh login,
so config sshd add `PermitRootLogin yes` for enable.
The following is to specify the `PermitRoot` parameter, 
use a another account to enable root account ssh login through `sudo`.

__NOTE: you will be asked for password multiple times__

```powershell
seed-ssh -PermitRoot xy@ub.lan
```

Enable root account on multiple hosts

```powershell
seed-ssh -PermitRoot xy@ub1,xy@ub2
```

After enable root login, 
you need to export the SSH key to the local machine, 
than the local machine can control these hosts.

__NOTE: A group of hosts only need one host for export, such as a docker-swarm cluster, only the manager node need be exported__

```powershell
seed-docker -Export root@ub.lan
```

__NOTE: Exported key will save in user home ssh directory `%userprofile%/.ssh/` and in the same folder as the hostname__

Finally, by authorizing the exported key to the host cluster, 
the local machine can login by SSH and control these hosts.


```powershell
seed-docker -Authorize root@ub.lan,root@ub1,root@ub2
```

At the same time, 
because the ssh key is generated and exported on the `-Export` host, 
the `-Export` host can also control these hosts like master-cluster.

Of course using parameters at the same time to combine multiple functions together.

```powershell
seed-ssh -root xy@ub.lan -export root@ub.lan -authorize root@ub.lan,root@ub1,root@ub2
```

### parameters


#### -PermitRoot

ssh *destination* list, like `xy@ub.lan`.

|  |  |
|:----- |:----- |
| Type: | String[] |
| Aliases: | root |
| Position:	| Named |
| Default value: | None |
| Accept pipeline input: | False |
| Accept wildcard characters: | False |


#### -Export

ssh *destination*, like `root@ub.lan`.

|  |  |
|:----- |:----- |
| Type: | String |
| Aliases: | e |
| Position:	| Named |
| Default value: | None |
| Accept pipeline input: | False |
| Accept wildcard characters: | False |


#### -Authorize

ssh *destination* list, like `xy@ub1,xy@ub2`.

|  |  |
|:----- |:----- |
| Type: | String[] |
| Aliases: | a |
| Position:	| Named |
| Default value: | False |
| Accept pipeline input: | False |
| Accept wildcard characters: | False |


#### -Options

same as `ssh` options.

|  |  |
|:----- |:----- |
| Type: | String |
| Aliases: | opt |
| Position:	| Named |
| Default value: | None |
| Accept pipeline input: | False |
| Accept wildcard characters: | False |




## continue to develop

test module manifest

```powershell
".\docker-seed\docker-seed.psd1" | Test-ModuleManifest | Format-List
```

publish module must have the same folder name as the module name

```powershell
Publish-Module -Path ".\docker-seed" -NuGetApiKey "?"
```