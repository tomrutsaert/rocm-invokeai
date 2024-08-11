# rocm-invokeai
DockerFile with Rocm and invokeai
- It hacks the invokeAI installer, so it does not need end-user input
- It hacks the installation to push rocm 6.1 on top of it

docker run example:

```
docker run --device /dev/kfd --device /dev/dri --publish 9090:9090 --security-opt seccomp=unconfined ghcr.io/tomrutsaert/rocm-invokeai
```

docker-compose exmpale see docker-compose.yml
