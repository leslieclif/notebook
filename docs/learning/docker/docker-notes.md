[Docker Mastery](https://github.com/bretfisher/udemy-docker-mastery)
[Docker Shell Config](https://www.bretfisher.com/shell/)
[Containers vs VM ebook](https://github.com/mikegcoleman/docker101/blob/master/Docker_eBook_Jan_2017.pdf)
[Docker Cgroup and Namespaces](https://www.youtube.com/watch?list=PLBmVKD7o3L8v7Kl_XXh3KaJl9Qw2lyuFl&v=sK5i-N34im8&
feature=youtu.be)

[Linux Package Management Basics](https://www.digitalocean.com/community/tutorials/package-management-basics-apt-yum-dnf-pkg)

[Formatting Docker CLI Output](https://docs.docker.com/config/formatting/)
[DNS Basics](https://howdns.works/)

[Docker Image](https://github.com/moby/moby/blob/master/image/spec/v1.md)

[Immutable Software](https://www.oreilly.com/radar/an-introduction-to-immutable-infrastructure/)
[12 factor App](https://12factor.net/)
[12 Fractured Apps](https://medium.com/@kelseyhightower/12-fractured-apps-1080c73d481c#.cjvkgw4b3)
[Docker Storage](https://docs.docker.com/storage/)

[YAML Spec Ref Card](https://yaml.org/refcard.html)

[Docker secrets](https://docs.docker.com/engine/swarm/secrets/)
[Healthcheck in Dockerfile](https://docs.docker.com/engine/reference/builder/#healthcheck)

[Docker Registry Config](https://docs.docker.com/registry/configuration/)
[Docker Registry Garbage Collection](https://docs.docker.com/registry/garbage-collection/)
[Docker Registry as cache](https://docs.docker.com/registry/recipes/mirror/)

[Docker CLI to kubectl](https://kubernetes.io/docs/reference/kubectl/docker-cli-to-kubectl/)
[kubectl best practises](https://kubernetes.io/docs/reference/kubectl/conventions/#best-practices)
[k8s Management techniques](https://kubernetes.io/docs/concepts/overview/working-with-objects/object-management/)

[Docker Security](https://github.com/BretFisher/ama/issues/17)
[Docker Engine Security](https://docs.docker.com/engine/security/)
[Docker Security Tools](https://sysdig.com/blog/20-docker-security-tools/)
[Seccomp](https://docs.docker.com/engine/security/seccomp/)
[App Armor](https://docs.docker.com/engine/security/apparmor/)
[Docker Bench](https://github.com/docker/docker-bench-security)
[CIS Docker checklist](https://www.cisecurity.org/benchmark/docker/)
[User Namespaces](https://integratedcode.us/2015/10/13/user-namespaces-have-arrived-in-docker/)
[Sysdig Falco](https://sysdig.com/opensource/falco/)
[Appamror Profiles](https://docs.docker.com/engine/security/apparmor/)
[Seccomp Profile](https://docs.docker.com/engine/security/seccomp/)

[]()

```
Starting container process caused "exec: \"ping\": executable file not found in $PATH": unknown

apt-get update && apt-get install -y iputils-ping
```

```
Starting mysql container and running ps causes "ps: command not found"
apt-get update && apt-get install procps
```