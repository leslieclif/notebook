- [Master list of Docker Resources and Projects](https://github.com/veggiemonk/awesome-docker#hosting-images-registries)
- [Play With Docker](http://training.play-with-docker.com/), a great resource for web-based docker testing and also has a library of labs built by Docker Captains and others, and supported by Docker Inc. 
- [Play With Docker Labs](http://labs.play-with-docker.com/)
- [DockerHub Recipes](https://docs.docker.com/registry/recipes/)
- [Docker Cloud: CI/CD and Server Ops](https://cloud.docker.com)

- [Docker Mastery](https://github.com/bretfisher/udemy-docker-mastery)
- [Bret's Podcast](https://podcast.bretfisher.com/episodes)
- [Bret's Youtube](https://www.youtube.com/channel/UC0NErq0RhP51iXx64ZmyVfg)
- [Dockerfile Best Practice](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
- [Docker Devops](https://www.youtube.com/watch?v=yeZqoh3-cME)
- [Docker Best practise inside a code repo](https://github.com/BretFisher/node-docker-good-defaults)
- [Docker Certificated Associate](https://www.bretfisher.com/docker-certified-associate/)
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

- [Devops Roadmap](https://github.com/kamranahmedse/developer-roadmap#devops-roadmap)
- [Docker Storage](https://docs.docker.com/storage/)

- [YAML Spec Ref Card](https://yaml.org/refcard.html)

- [Docker secrets](https://docs.docker.com/engine/swarm/secrets/)
- [Healthcheck in Dockerfile](https://docs.docker.com/engine/reference/builder/#healthcheck)

- [Docker Registry Config](https://docs.docker.com/registry/configuration/)
- [Docker Registry Garbage Collection](https://docs.docker.com/registry/garbage-collection/)
- [Docker Registry as cache](https://docs.docker.com/registry/recipes/mirror/)

- [Docker CLI to kubectl](https://kubernetes.io/docs/reference/kubectl/docker-cli-to-kubectl/)

- [Docker and Pi Projects](https://blog.alexellis.io/tag/raspberry-pi/)

```BASH
Starting container process caused "exec: \"ping\": executable file not found in $PATH": unknown

apt-get update && apt-get install -y iputils-ping
```

```BASH
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

```DOCKER
docker container run --publish 80:80 --detach --name webhost nginx
docker container run -it - start new container interactively
docker container exec -it - run additional command in
existing container
docker container ls -a
docker container logs webhost
```

## Container VS. VM: It's Just a Process

```DOCKER
docker run --name mongo -d mongo
docker container top - process list in one container
docker stop mongo
docker ps
docker start mongo
docker container inspect - details of one container config
docker container stats - performance stats for all containers
```
## The Mighty Hub: Using Docker Hub Registry Images
```DOCKER
docker pull nginx
docker image ls
```
## Images and Their Layers: Discover the Image Cache
```DOCKER
docker history nginx:latest
docker image inspect nginx
```
## Image Tagging and Pushing to Docker Hub
```DOCKER
docker pull nginx:latest
docker image ls
docker image tag nginx bretfisher/nginx
docker login
cat .docker/config.json
docker image push bretfisher/nginx
docker image push bretfisher/nginx bretfisher/nginx:testing
```
## Getting a Shell Inside Containers: No Need for SSH
```DOCKER
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
```DOCKER
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
```DOCKER
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
```DOCKER
docker container run -d --name my_nginx --network my_app_net nginx
docker container exec -it my_nginx ping new_nginx
docker container exec -it new_nginx ping my_nginx
```
## DNS Round Robin Testing
```DOCKER
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
```DOCKER
docker container run -d --name mysql -e MYSQL_ALLOW_EMPTY_PASSWORD=True -v mysql-db:/var/lib/mysql mysql
docker volume ls
docker volume inspect mysql-db
```
## Persistent Data: Bind Mounting
- Used for local development
- Usecase: When you are changing files on laptop which you want to serve in the app
- It can be run only during `docker run` as there is no explicit volume command in the dockerfile
- the volume will be mounted in the working directory of the container
```DOCKER
docker container run -d --name nginx -p 80:80 -v $(pwd):/usr/share/nginx/html nginx
docker container exec -it nginx -- bash
cd /usr/share/nginx/html && ls -la
```
- docker log streaming
```DOCKER
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
```DOCKER
docker-compose up # setup volumes/networks and start all containers
docker-compose down # stop all containers and remove cont/vol/net
```
## Trying Out Basic Compose Commands

```DOCKER
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

```DOCKER
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
```DOCKER
docker-machine create node1
docker-machine ssh node1
docker-machine env node1
```
```DOCKER
docker swarm init
docker swarm init --advertise-addr node1
docker node ls
docker node update --role manager node2 # Update role to existing node
docker swarm join-token manager # Shows join token for manager role
docker service create --replicas 3 alpine ping 8.8.8.8 # Creates service with 3 replicas and starts ping process
```
```DOCKER
docker service ls
docker service ps <service name>
docker node ps
docker node ps node2
```
## Scaling Out with Overlay Networking

```DOCKER
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
## Scaling Out with Routing Mesh
```DOCKER
docker service create --name search --replicas 3 -p 9200:9200 elasticsearch:2
docker service ps search
```
## Create a Multi-Service Multi-Node Web App
```DOCKER
docker network create -d overlay backend
docker network create -d overlay frontend
docker service create --name vote -p 80:80 --network frontend \
-- replica 2 dockersamples/examplevotingapp_vote:before
docker service create --name redis --network frontend \
--replica 1 redis:3.2
docker service create --name worker --network frontend --network backend dockersamples/examplevotingapp_worker
docker service create --name db --network backend \
--mount type=volume,source=db-data,target=/var/lib/postgresql/data postgres:9.4 
docker service create --name result --network backend -p 5001:80 COPY INFO
docker service ls
docker service logs worker
```
## Swarm Stacks and Production Grade Compose
- Docker adds a new layer of abstraction to Swarm called
Stacks
- Stacks accept Compose files as their declarative definition for
services, networks, and volumes
- We use `docker stack deploy` rather then `docker service create`
- Stacks manages all those objects for us, including overlay network
per stack. Adds stack name to start of their name
- Compose now ignores `deploy:`, Swarm ignores `build:`
```DOCKER
docker stack deploy -c example-voting-app-stack.yml voteapp
docker stack ls
docker stack services voteapp
docker stack ps voteapp
```
## Using Secrets in Swarm Services
What is a Secret?
- Usernames and passwords
- TLS certificates and keys
- SSH keys
- Any data you would prefer not be "on front page of news"
```DOCKER
docker secret create psql_usr psql_usr.txt
echo "myDBpassWORD" | docker secret create psql_pass - TAB COMPLETION
docker secret inspect psql_usr
docker service create --name psql --secret psql_user \
--secret psql_pass -e POSTGRES_PASSWORD_FILE=/run/secrets/psql_pass \
-e POSTGRES_USER_FILE=/run/secrets/psql_user postgres
docker exec -it <container name> bash
cat /run/secrets/psql_user
```
# Swarm App Lifecycle
## Full App Lifecycle: Dev, Build and Deploy With a Single Compose Design
Single set of Compose files for:
- Local `docker-compose up` development environment
- Remote `docker-compose up` CI environment
- Remote `docker stack deploy` production environment
```DOCKER
docker-compose -f docker-compose.yml -f docker-compose.test.yml up -d
docker-compose -f docker-compose.yml -f docker-compose.prod.yml config
```
## Service Updates: Changing Things In Flight
- Provides rolling replacement of tasks/containers in a service
- Limits downtime (be careful with "prevents" downtime)
- Will replace containers for most changes
- Has many, many cli options to control the update
- Create options will usually change, adding -add or -rm to them
- Includes rollback and healthcheck options
- Also has scale & rollback subcommand for quicker access
  `docker service scale web=4` and `docker service rollback web`
- Just update the image used to a newer version
 `docker service update --image myapp:1.2.1 <servicename>`
- Adding an environment variable and remove a port
 `docker service update --env-add NODE_ENV=production --publish-rm 8080`
- Change number of replicas of two services
 `docker service scale web=8 api=6`
```DOCKER
docker service create -p 8088:80 --name web nginx:1.13.7
docker service scale web=5
docker service update --image nginx:1.13.6 web
docker service update --publish-rm 8088 --publish-add 9090:80
docker service update --force web # forces rebalancing of the service without changing anything
docker service rm web
```
## Healthchecks in Dockerfiles
- HEALTHCHECK was added in 1.12
- Supported in Dockerfile, Compose YAML, docker run, and Swarm Services
- Docker engine will exec's the command in the container (e.g. curl localhost)
- It expects exit 0 (OK) or exit 1 (Error)
- Three container states: starting, healthy, unhealthy
- Much better then "is binary still running?"
- Options for healthcheck command
```DOCKER
--interval=DURATION (default: 30s)
--timeout=DURATION (default: 30s)
--start-period=DURATION (default: 0s) (17.09+)
--retries=N (default: 3)
```
```DOCKER
docker container run --name p2 -d --health-cmd="pg_isready \
-U postgres || exit 1" postgres
docker service create --name p2 --health-cmd="pg_isready \
-U postgres || exit 1" postgres
```
# Container Registries: Image Storage and Distribution
## Run a Private Docker Registry
- Secure your Registry with TLS
- Storage cleanup via Garbage Collection
- Enable Hub caching via "--registry-mirror"

```DOCKER
# Run the registry image
docker container run -d -p 5000:5000 --name registry registry
# Re-tag an existing image and push it to your new registry
docker pull hello-world
docker run hello-world
docker tag hello-world 127.0.0.1:5000/hello-world
docker push 127.0.0.1:5000/hello-world
# Remove that image from local cache and pull it from new registry
docker image remove hello-world
docker image remove 127.0.0.1:5000/hello-world
docker pull 127.0.0.1:5000/hello-world:latest
# Re-create registry using a bind mount and see how it stores data
docker container kill registry
docker container rm registry
docker container run -d -p 5000:5000 --name registry -v $(pwd)/registry-data:/var/lib/registry registry
```
## Using Docker Registry With Swarm
```DOCKER
docker node ls
docker service create --name registry --publish 5000:5000 registry
docker service ps registry
docker pull nginx
docker tag nginx 127.0.0.1:5000/nginx
docker push 127.0.0.1:5000/nginx
docker service create --name nginx -p 80:80 --replicas 5 --detach=false 127.0.0.1:5000/nginx
docker service ps nginx
```
## Using Docker in Production
- Focus on Dockerfiles first. 
- Study ENTRYPOINT of Hub official images. Use it for config of images before CMD is executed.
- use ENTRYPOINT to set default values for all environments and then overide using ENV values.
- [EntryPoint vs CMD](http://www.johnzaccone.io/entrypoint-vs-cmd-back-to-basics/)
- FROM official distros.
- Make it == start, log all things in stdout/stderr, documented in file, lean and scale.
- Using SaaS for - Image Registry, Logging, Monitoring, Look at CNCF Landscape
- Using Layer 7 Reverse Proxy if port 80 and 443 are used by multiple apps

# Docker Security

- [Docker Security Checklist](https://github.com/BretFisher/ama/issues/17)
- [Docker Engine Security](https://docs.docker.com/engine/security/)
- [Docker Security Tools](https://sysdig.com/blog/20-docker-security-tools/)
- [Seccomp](https://docs.docker.com/engine/security/seccomp/)
- [App Armor](https://docs.docker.com/engine/security/apparmor/)
- [Docker Bench](https://github.com/docker/docker-bench-security)
- [CIS Docker checklist](https://www.cisecurity.org/benchmark/docker/)
- Running Docker as non root user
```DOCKER
# Creating non root user in alpine
RUN addgroup -g 1000 node \
    && adduser -u 1000 -G node -s /bin/sh -D node
# Creating non root user in stretch
RUN groupadd --gid 1000 node \
  && useradd --uid 1000 --gid node --shell /bin/bash --create-home node
```
- Sample Dockerfile with [USER](https://github.com/BretFisher/dockercon19/blob/master/1.Dockerfile)
- [User Namespaces](https://integratedcode.us/2015/10/13/user-namespaces-have-arrived-in-docker/)
- [Shift Left Security](https://www.paloaltonetworks.com/prisma/cloud)
- [Trivy - Image Scanning](https://github.com/aquasecurity/trivy#os-packages)
- [Sysdig Falco](https://sysdig.com/opensource/falco/)
- [Appamror Profiles](https://docs.docker.com/engine/security/apparmor/)
- [Seccomp Profile](https://docs.docker.com/engine/security/seccomp/)

# Docker Context
- Start a node on paly with Docker
- Copy the IP of the node
- Set the Docker Context with the Host Name of the node and port 2375
- Contexts are created in the home folder of user called `.docker/context`

```DOCKER
docker context create --docker "host=tcp://<Host Name>:2375" <context-name>
docker context ls
docker context use <context-name>
docker ps # Should show the new context of play with docker
# Overriding Context to default in commandline
docker -c default ps
docker -c <context-name> ps
# Looping through all the context and executing ps
for c in `docker context ls -q`; do `docker -c $c ps`; done
# Creates the image in all context
for c in `docker context ls -q`; do `docker -c $c run hello-world`; done
```
# Recommendations
- To change permissions on file system (chown or chmod) use a Entrypoint script. Look up to official images for examples for Entrypoint
- One App or Website use one container, specially if using an orchestrator like K8s or Docker Swarm. Scaling is also a benefit due to one-one relationship.
- [Changing Docker IP range](https://serverfault.com/questions/916941/configuring-docker-to-not-use-the-172-17-0-0-range/942176#942176)
- Use Cloud DB as service instead of in containers
- Run one process per container
- Strict Separation of Config from Code. Use Env variables to achieve this. [Using Development workflow in Compose](https://www.oreilly.com/content/3-docker-compose-features-for-improving-team-development-workflow/)
- Write all the ENV variables at the top of Dockerfile
- Using Env variables in [Dockerfile](https://github.com/BretFisher/php-docker-good-defaults/blob/master/Dockerfile)
- Override Env variables in [Docker Compose file](https://github.com/BretFisher/php-docker-good-defaults/blob/master/docker-compose.yml) say for Dev testing
- Using Env variables in [Docker Entrypoint](https://github.com/BretFisher/php-docker-good-defaults/blob/master/docker-php-entrypoint) to write into Application config files during start up.
- Secrets and Application specific config goes into specific ENV var blocks. Tis can be changed. Defaults or data specific to SERVER or LANGUAGE goes to another ENV block and can be kept static. This avoids them being set for each ENV.
- Encrypting traffic for local development use [Lets Encrypt](https://letsencrypt.org/docs/certificates-for-localhost/) ad store them in .cert folder in Home Directory.
- Encrypting traffic for production use Lets Encrypt and maybe [Traefik](https://traefik.io/) as Front proxy. See [example](https://github.com/BretFisher/dogvscat) using Swarm
- COPY vs ADD. Use COPY to copy artefacts in the same repo to the image. Use ADD when you want to download something from the Internet or to untar or unzip. You can also replace using wget statements with ADD.
- Combine multiple RUN into a single statement. 
- Delete packages which are downloaded and installed also in a single command to save image size.
- No secrets like configs, certificates should be saved in Image. Pass them during runtime.
- Always have a CMD in the image, even if its inheriting it from BASE image
- Version apt packages and BASE images
- Use multistage Dokcer builds to have Dev dependencies and Prod dependencies separate.
- Have healthchecks in K8s instead of Dockerfile
- Use DNS RoundRobin for Database inside Compose file so it switches of Virtual IP on the Overlay network and gives direct access from FrontEnd Service to Backend container.
- Setting resource limits inside Compose file
- DRY your compose files using templates
- 
```DOCKER
```
```DOCKER
```
```DOCKER
```
```DOCKER
```
```DOCKER
```
```DOCKER
```
```DOCKER
```
```DOCKER
```
```DOCKER
```
```DOCKER
```
```DOCKER
```
```DOCKER
```
```DOCKER
```
```DOCKER
```
```DOCKER
```

