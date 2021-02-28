- [Docker Mastery](https://github.com/bretfisher/udemy-docker-mastery)
- [Docker Shell Config](https://www.bretfisher.com/shell/)
- [Containers vs VM ebook](https://github.com/mikegcoleman/docker101/blob/master/Docker_eBook_Jan_2017.pdf)

- Docker Cgroup and Namespaces

- [Linux Package Management Basics](https://www.digitalocean.com/community/tutorials/package-management-basics-apt-yum-dnf-pkg)

- [Formatting Docker CLI Output](https://docs.docker.com/config/formatting/)

- [Dockerfile Reference](https://docs.docker.com/engine/reference/builder/)

- [DNS Basics](https://howdns.works/)

- [Docker Image](https://github.com/moby/moby/blob/master/image/spec/v1.md)

- [Immutable Software](https://www.oreilly.com/radar/an-introduction-to-immutable-infrastructure/)
- [12 factor App](https://12factor.net/)
- [12 Fractured Apps](https://medium.com/@kelseyhightower/12-fractured-apps-1080c73d481c#.cjvkgw4b3)
- [Docker Storage](https://docs.docker.com/storage/)

- [YAML Spec Ref Card](https://yaml.org/refcard.html)

- [Docker secrets](https://docs.docker.com/engine/swarm/secrets/)
- [Healthcheck in Dockerfile](https://docs.docker.com/engine/reference/builder/#healthcheck)

- [Docker Registry Config](https://docs.docker.com/registry/configuration/)
- [Docker Registry Garbage Collection](https://docs.docker.com/registry/garbage-collection/)
- [Docker Registry as cache](https://docs.docker.com/registry/recipes/mirror/)

- [Docker CLI to kubectl](https://kubernetes.io/docs/reference/kubectl/docker-cli-to-kubectl/)
- [kubectl best practises](https://kubernetes.io/docs/reference/kubectl/conventions/#best-practices)
- [k8s Management techniques](https://kubernetes.io/docs/concepts/overview/working-with-objects/object-management/)

- [Docker Security](https://github.com/BretFisher/ama/issues/17)
- [Docker Engine Security](https://docs.docker.com/engine/security/)
- [Docker Security Tools](https://sysdig.com/blog/20-docker-security-tools/)
- [Seccomp](https://docs.docker.com/engine/security/seccomp/)
- [App Armor](https://docs.docker.com/engine/security/apparmor/)
- [Docker Bench](https://github.com/docker/docker-bench-security)
- [CIS Docker checklist](https://www.cisecurity.org/benchmark/docker/)
- [User Namespaces](https://integratedcode.us/2015/10/13/user-namespaces-have-arrived-in-docker/)
- [Sysdig Falco](https://sysdig.com/opensource/falco/)
- [Appamror Profiles](https://docs.docker.com/engine/security/apparmor/)
- [Seccomp Profile](https://docs.docker.com/engine/security/seccomp/)

```sh
Starting container process caused "exec: \"ping\": executable file not found in $PATH": unknown

apt-get update && apt-get install -y iputils-ping
```

```sh
Starting mysql container and running ps causes "ps: command not found"
apt-get update && apt-get install procps
```

[Dockerfile Reference](https://docs.docker.com/engine/reference/builder/)

# Creating and Using Containers Like a Boss

## Check Our Docker Install and Config
- `docker version` - verified cli can talk to engine
- `docker info` - most config values of engine

## Image vs. Container
- An Image is the application we want to run
- A Container is an instance of that image running as a process
- You can have many containers running off the same image
- Docker's default image "registry" is called [Docker Hub](hub.docker.com)

```docker
docker container run --publish 80:80 --detach --name webhost nginx
docker container run -it - start new container interactively
docker container exec -it - run additional command in
existing container
docker container ls -a
docker container logs webhost
```

## Container VS. VM: It's Just a Process

```docker
docker run --name mongo -d mongo
docker container top - process list in one container
docker stop mongo
docker ps
docker start mongo
docker container inspect - details of one container config
docker container stats - performance stats for all containers
```
## The Mighty Hub: Using Docker Hub Registry Images
```docker
docker pull nginx
docker image ls
```
## Images and Their Layers: Discover the Image Cache
```docker
docker history nginx:latest
docker image inspect nginx
```
## Image Tagging and Pushing to Docker Hub
```docker
docker pull nginx:latest
docker image ls
docker image tag nginx bretfisher/nginx
docker login
cat .docker/config.json
docker image push bretfisher/nginx
docker image push bretfisher/nginx bretfisher/nginx:testing
```
## Getting a Shell Inside Containers: No Need for SSH
```docker
docker container exec -it mysql -- bash
docker container run -it alpine -- bash
docker container run -it alpine -- sh
```
## Cleaning Docker images
- Use `docker system df` to see space usage. 
- `docker image prune` to clean up just "dangling" images.
- The big one is usually `docker image prune -a` which will remove all images you're not using. 
- `docker volume prune` to remove unused volumes
- `docker system prune` will clean up everything (Nuke everything that is not used currently).
- `docker system prune -a` wipe everything.

## Docker Networks: Concepts for Private and Public Comms in Containers
- Each container connected to a private virtual network "bridge"
- Each virtual network routes through NAT firewall on host IP
- All containers on a virtual network can talk to each other
without -p
- Best practice is to create a new virtual network for each app:
- network "my_web_app" for mysql and php/apache containers
- network "my_api" for mongo and nodejs containers
```docker
docker container run -p 80:80 --name webhost -d nginx
docker container port webhost
docker container inspect --format '{{ .NetworkSettings.IPAddress }}' webhost
```
## Docker Networks: CLI Management of Virtual Networks
- Show networks `docker network ls`
- Inspect a network `docker network inspect`
- Create a network `docker network create --driver`
- Attach a network to container `docker network connect`
- Detach a network from container `docker network disconnect`
```docker
docker network ls
docker network inspect bridge
docker network create my_app_net
docker container run -d --name new_nginx --network my_app_net nginx
docker network inspect my_app_net
docker network connect <new network id> <container id>
docker container disconnect <new network id> <container id>
```
## Docker Networks: DNS and How Containers Find Each Other
- Create your apps so frontend/backend sit on same Docker
network
- Their inter-communication never leaves host
- All externally exposed ports closed by default
- You must manually expose via -p , which is better default
security!
- Containers shouldn't rely on IP's for inter-communication
- DNS for friendly names is built-in if you use custom networks
```docker
docker container run -d --name my_nginx --network my_app_net nginx
docker container exec -it my_nginx ping new_nginx
docker container exec -it new_nginx ping my_nginx
```
## DNS Round Robin Testing
```docker
docker network create dude
docker container run -d --net dude --net-alias search elasticsearch:2
docker container ls
docker container run --rm -- net dude alpine nslookup search
docker container run --rm --net dude centos curl -s search:9200
```

# Container Lifetime & Persistent Data: Volumes, Volumes, Volumes

## Persistent Data: Data Volumes
- Containers are usually immutable and ephemeral
- "immutable infrastructure": only re-deploy containers, never change
- This is the ideal scenario, but what about databases, or unique
data?
- Docker gives us features to ensure these "separation of concerns"
- This is known as "persistent data"
- Two ways: Volumes and Bind Mounts
- *Volumes*: make special location outside of container UFS
- *Bind Mounts*: link container path to host path
```docker
docker container run -d --name mysql -e MYSQL_ALLOW_EMPTY_PASSWORD=True -v mysql-db:/var/lib/mysql mysql
docker volume ls
docker volume inspect mysql-db
```
## Persistent Data: Bind Mounting
- Used for local development
- Usecase: When you are changing files on laptop which you want to serve in the app
- It can be run only during `docker run` as there is no explicit volume command in the dockerfile
- the volume will be mounted in the working directory of the container
```docker
docker container run -d --name nginx -p 80:80 -v $(pwd):/usr/share/nginx/html nginx
docker container exec -it nginx -- bash
cd /usr/share/nginx/html && ls -la
```
- docker log streaming
```docker
docker container logs -f <container name>
```
## Database Passwords in Containers
- When running postgres now, you'll need to either set a password, or tell it to allow any connection (which was the default before this change).
-you need to either set a password with the environment variable:
`POSTGRES_PASSWORD=mypasswd`
- Or tell it to ignore passwords with the environment variable:
`POSTGRES_HOST_AUTH_METHOD=trust`

# Making It Easier with Docker Compose: The Multi-Container Tool
- Why: configure relationships between containers
- Why: save our docker container run settings in easy-to-read file
- Why: create one-liner developer environment startups
- YAML-formatted file that describes our solution options for:
  containers, networks, volumes
- A CLI tool `docker-compose` used for local dev/test
automation with those YAML files
- `docker-compose.yml` is default filename, but any can be
used with `docker-compose -f`
- Not a production-grade tool but ideal for local development and test
- Two most common commands are:
```docker
docker-compose up # setup volumes/networks and start all containers
docker-compose down # stop all containers and remove cont/vol/net
```
## Trying Out Basic Compose Commands

```docker
docker-compose up
docker-compose up -d  # Running compose in bacground
docker-compose down
docker-compose down -v --rmi local/all # Removes images and volumes
# Compose operations
docker-compose logs
docker-compose ps
docker-compose top

docker-compose build # Build images or
docker-compose up --build
```
# Swarm Intro and Creating a 3-Node Swarm Cluster
- Swarm Mode is a clustering solution built inside Docker
- Not enabled by default

## docker swarm init: What Just Happened?
- Lots of PKI and security automation
- Root Signing Certificate created for our Swarm
- Certificate is issued for first Manager node
- Join tokens are created
- Raft database created to store root CA, configs and secrets
- Encrypted by default on disk (1.13+)
- No need for another key/value system to hold orchestration/secrets
- Replicates logs amongst Managers via mutual TLS in "control plane"
## Create Your First Service and Scale it Locally

```docker
docker info # swarm is down by default
docker swarm init # start swarm
docker node ls
docker service create alpine ping 8.8.8.8 # creates service frosty_newton
docker service ls
docker service ps frosty_newton
docker container ls
docker service update frosty_newton --replicas 3 # creates 3 replicas
docker service ls
docker service rm frosty_newton # deletes the service
docker service ls
docker container ls
```
## Creating a 3-Node Swarm Cluster
*docker-machine + VirtualBox*
- Free and runs locally, but requires a machine with 8GB memory
```docker
docker-machine create node1
docker-machine ssh node1
docker-machine env node1
```
```docker
docker swarm init
docker swarm init --advertise-addr node1
docker node ls
docker node update --role manager node2 # Update role to existing node
docker swarm join-token manager # Shows join token for manager role
docker service create --replicas 3 alpine ping 8.8.8.8 # Creates service with 3 replicas and starts ping process
```
```docker
docker service ls
docker service ps <service name>
docker node ps
docker node ps node2
```
## Scaling Out with Overlay Networking

```docker
# Create Backend network
docker network create --driver overlay mydrupal
docker network ls
docker service create --name psql --netowrk mydrupal -e POSTGRES_PASSWORD=mypass postgres
docker service ls
docker service ps psql
docker container logs psql <container name>
# Create Frontend network
docker service create --name drupal --network mydrupal -p 80:80 drupal
docker service inspect drupal
```

```docker
```
```docker
```
```docker
```
```docker
```
```docker
```
```docker
```
```docker
```
```docker
```
```docker
```
```docker
```
```docker
```
```docker
```
```docker
```
```docker
```
```docker
```
```docker
```
```docker
```
```docker
```
```docker
```
```docker
```
```docker
```
```docker
```
```docker
```
```docker
```
```docker
```

