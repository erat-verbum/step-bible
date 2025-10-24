### building
```sh
docker build \
    --build-arg STEP_DEB_URL=https://.../new_stepbible_version.deb \
    --build-arg STEP_DEB_SHA256=a1b2c3d4...your...new...checksum... \
    -t step_bible_docker .
```

**To build using the default values (as specified in the file):**
```sh
docker build -t step_bible_docker .
```

### running it
```sh
docker run -it --rm --network=host -v ${HOME}/.sword:/home/step/.sword step_bible_docker
```
