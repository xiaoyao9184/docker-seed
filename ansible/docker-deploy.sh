#!/bin/bash
name=$1

if [[ -z "$name" ]]
then
    name=$DOCKER_STACK_NAME
fi

if [[ -f ./docker-compose.yml ]]
then
    echo "find docker-compose run up."
    docker-compose -p "$name" -d up
fi
if [[ -f ./docker-compose-swarm.yml ]]
then
    echo "find docker-compose-swarm run deploy."
    docker stack deploy \
        -c ./docker-compose-swarm.yml \
        $name
fi
