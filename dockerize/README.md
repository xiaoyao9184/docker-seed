

## Build

in [dockerize](./) of this project

```sh
DOCKER_BUILDKIT=1 docker build -t xiaoyao9184/docker-seed-dockerize:dev -f ./Dockerfile . 
```

```bat
SET DOCKER_BUILDKIT=1&& docker build -t xiaoyao9184/docker-seed-dockerize:dev -f ./Dockerfile . 
```

```powershell
SET DOCKER_BUILDKIT=1&& docker build -t xiaoyao9184/docker-seed-dockerize:dev -f ./Dockerfile . 
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
 xiaoyao9184/docker-seed-dockerize:dev
```

```bat
:: windows batch for Docker Desktop Linux containers mode
docker run ^
 --rm ^
 -it ^
 -e TZ=Asia/Hong_Kong ^
 -v /etc/localtime:/etc/localtime:ro ^
 --entrypoint="/bin/bash" ^
 xiaoyao9184/docker-seed-dockerize:dev
```

```powershell
# powershell for linux docker
docker run `
 --rm `
 -it `
 -e TZ=Asia/Hong_Kong `
 -v /etc/localtime:/etc/localtime:ro `
 --entrypoint="/bin/bash" `
 xiaoyao9184/docker-seed-dockerize:dev
```

then you can check dockerize command

```sh
dockerize --help
```

or run any entrypoint script like this

```sh
bash /docker-entrypoint.sh
```

or mock invoke with environment variables

```sh
DOCKERIZE_WAIT_RETRY_INTERVAL=5s DOCKERIZE_WAIT=https://github.com/ DOCKERIZE_WAIT_1=https://raw.githubusercontent.com/ bash /docker-entrypoint.sh
```