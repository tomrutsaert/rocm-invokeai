# rocm-invokeai

DOES NOT WORK, although it starts and show using the amd gpu, it crashes without error message when doing actually work


DockerFile with Rocm and invokeai
- It hacks the invokeAI installer, so it does not need end-user input
- It hacks the installation to push rocm 6.1 on top of it

docker run example:

```
docker run --device /dev/kfd --device /dev/dri --publish 9090:9090 --security-opt seccomp=unconfined ghcr.io/tomrutsaert/rocm-invokeai:main
```

docker-compose exmpale see docker-compose.yml
