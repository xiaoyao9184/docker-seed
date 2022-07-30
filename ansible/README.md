

## Build

in [ansible](./) of this project

```sh
DOCKER_BUILDKIT=1 docker build -t xiaoyao9184/docker-seed-ansible:dev -f ./Dockerfile . 
```

```bat
SET DOCKER_BUILDKIT=1&& docker build -t xiaoyao9184/docker-seed-ansible:dev -f ./Dockerfile . 
```

```powershell
SET DOCKER_BUILDKIT=1&& docker build -t xiaoyao9184/docker-seed-ansible:dev -f ./Dockerfile . 
```

go inside container 

```sh
# bash for linux docker
docker run \
 --rm \
 -it \
 -e TZ=Asia/Hong_Kong \
 -v /etc/localtime:/etc/localtime:ro \
 -v /var/run/docker.sock:/var/run/docker.sock \
 --entrypoint="/bin/bash" \
 xiaoyao9184/docker-seed-ansible:dev
```

```bat
:: windows batch for Docker Desktop Linux containers mode
docker run ^
 --rm ^
 -it ^
 -e TZ=Asia/Hong_Kong ^
 -v /etc/localtime:/etc/localtime:ro ^
 -v /var/run/docker.sock:/var/run/docker.sock ^
 --entrypoint="/bin/bash" ^
 xiaoyao9184/docker-seed-ansible:dev
```

```powershell
# powershell for linux docker
docker run `
 --rm `
 -it `
 -e TZ=Asia/Hong_Kong `
 -v /etc/localtime:/etc/localtime:ro `
 -v /var/run/docker.sock:/var/run/docker.sock `
 --entrypoint="/bin/bash" `
 xiaoyao9184/docker-seed-ansible:dev
```

then you can check ansible command

```sh
ansible --version
```

or run any entrypoint script like this

```sh
bash /docker-entrypoint.sh
```

or mock invoke with environment variables

```sh
ANSIBLE_EXTRA_VARS_0="host=github.com" ANSIBLE_EXTRA_VARS_1="delay=10" ANSIBLE_EXTRA_VARS_2="timeout=3000000" DOCKER_STACK_NAME="test" bash /docker-entrypoint.sh
```