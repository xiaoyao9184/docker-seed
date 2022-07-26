

## Build

in [wait4x](./) of this project

```sh
DOCKER_BUILDKIT=1 docker build -t xiaoyao9184/docker-seed-wait4x:dev -f ./Dockerfile . 
```

```bat
SET DOCKER_BUILDKIT=1&& docker build -t xiaoyao9184/docker-seed-wait4x:dev -f ./Dockerfile . 
```

```powershell
SET DOCKER_BUILDKIT=1&& docker build -t xiaoyao9184/docker-seed-wait4x:dev -f ./Dockerfile . 
```

go inside container 

```sh
# bash for linux docker
docker run \
 --rm \
 -it \
 -e TZ=Asia/Hong_Kong \
 -v /etc/localtime:/etc/localtime:ro \
 --entrypoint="/bin/bash" \
 xiaoyao9184/docker-seed-wait4x:dev
```

```bat
:: windows batch for Docker Desktop Linux containers mode
docker run ^
 --rm ^
 -it ^
 -e TZ=Asia/Hong_Kong ^
 -v /etc/localtime:/etc/localtime:ro ^
 --entrypoint="/bin/bash" ^
 xiaoyao9184/docker-seed-wait4x:dev
```

```powershell
# powershell for linux docker
docker run `
 --rm `
 -it `
 -e TZ=Asia/Hong_Kong `
 -v /etc/localtime:/etc/localtime:ro `
 --entrypoint="/bin/bash" `
 xiaoyao9184/docker-seed-wait4x:dev
```

then you can check wait4x command

```sh
wait4x --help
```

or run any entrypoint script like this

```sh
bash /docker-entrypoint.sh
```

or mock invoke with environment variables

```sh
WAIT4X_EXPECT_STATUS_CODE=200 WAIT4X_HTTP=https://raw.githubusercontent.com/ bash /docker-entrypoint.sh
```