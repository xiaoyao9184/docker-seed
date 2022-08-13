# docker-seed



docker-seed is docker container to control the docker machine 

## local mode

all type of docker-seed support this mode,
it mean docker-seed run and control in same docker machine.

So its dind control, docker-seed must mount to host `/var/run/docker.sock` docker api
```
┌──docker-machine─────────────────────────────────────────────────┐
│                                                                 │
│  ┌──docker───────────────────────────────────────────────────┐  │
│  │                                                           │  │
│  │  ┌──container────┐  ┌──container────┐  ┌──container────┐  │  │
│  │  │               │  │               │  │               │  │  │
│  │  │  docker-seed  │  │               │  │               │  │  │
│  │  │               │  │               │  │               │  │  │
│  │  │               │  │               │  │               │  │  │
│  │  │  docker-cli   │  │               │  │               │  │  │
│  │  │      │        │  │               │  │               │  │  │
│  │  └──────┼────────┘  └───────────────┘  └───────────────┘  │  │
│  │         │                                                 │  │
│  └─────────┼──────────────────────────────────▲──────────────┘  │
│            │                                  │                 │
│            │                                  │                 │
│            └────────►/var/run/docker.sock─────┘                 │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

docker-seed is job-syle container not service-syle container, 
when docker-seed run done the container will stop.

So in this mode, docker-seed cant run `docker compose` with local volume,
Because local refers to the inside of docker-seed container, 
but the container has stoped, 
and its local files are naturally destroyed.


## remote mode

docker-seed-ansible support control remote host through SSH, 
so docker-seed-ansible can run on other docker machine.

```
┌─docker-machine────────┐ ┌─docker-machine────────────────────────┐
│                       │ │                                       │
│  ┌─docker──────────┐  │ │  ┌─docker───────────────────────────┐ │
│  │                 │  │ │  │                                  │ │
│  │ ┌─container───┐ │  │ │  │ ┌─container───┐  ┌─container───┐ │ │
│  │ │             │ │  │ │  │ │             │  │             │ │ │
│  │ │ docker-seed │ │  │ │  │ │             │  │             │ │ │
│  │ │             │ │  │ │  │ │             │  │             │ │ │
│  │ │   ansible   │ │  │ │  │ │             │  │             │ │ │
│  │ │  -playbook  │ │  │ │  │ │             │  │             │ │ │
│  │ │      │      │ │  │ │  │ │             │  │             │ │ │
│  │ └──────┼──────┘ │  │ │  │ └─────────────┘  └─────────────┘ │ │
│  │        │        │  │ │  │                                  │ │
│  └────────┼────────┘  │ │  └──────────────────────────────────┘ │
│           │           │ │                              ▲        │
└───────────┼───────────┘ │         /var/run/docker.sock─┘        │
            │             │                        ▲              │
            │             │         docker-cli─────┘              │
            │             │                 ▲                     │
            └─────ssh─────┼────────►python──┘                     │
                          │                                       │
                          └───────────────────────────────────────┘
```

in this mode, the control is through SSH first, and then through the docker-api, 
which require that the controlled host must expose the SSH service to the outside. 

Although most hosts can do it, but Windows cannot, If you are using Windows with docker-desktop, you will not be able to use this mode, and ansible is not very compatible with controlled Windows systems.
