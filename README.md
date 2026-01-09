### building

**Using docker-compose (recommended):**
```sh
docker-compose build
```

**Using docker build:**
```sh
docker build -t step_bible_docker .
```

### running it

**Using docker-compose (recommended):**
```sh
docker-compose up -d
```

To stop the container:
```sh
docker-compose down
```

**Using docker run:**
```sh
docker run -it --rm -p 8989:8989 -v ${HOME}/.sword:/home/step/.sword step_bible_docker
```

### Notes

- The Dockerfile now automatically downloads the latest version of StepBible from the official website
- No need to manually specify download URLs or checksums
- The container uses host networking and mounts your local `.sword` directory for Bible module storage
- The docker-compose configuration provides an easy way to manage the container lifecycle
