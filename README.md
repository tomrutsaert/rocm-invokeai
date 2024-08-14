# rocm-invokeai
DockerFile with Rocm and invokeai
- It hacks the invokeAI installer, so it does not need end-user input
- It hacks the installation to push rocm 6.1 on top of it

docker run example:

```
docker run --device /dev/kfd --device /dev/dri --publish 9090:9090 --security-opt seccomp=unconfined -v ~/invokeai:/invokeai ghcr.io/tomrutsaert/rocm-invokeai:main
```

docker-compose example see docker-compose.yml
