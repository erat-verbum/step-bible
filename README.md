# StepBible Docker

This Docker setup allows you to run StepBible, a graphical Bible study application, in a containerized environment. The configuration includes a virtual display setup to enable graphical rendering in a headless environment.

## Prerequisites

- Docker installed on your system
- Docker Compose (for recommended usage)

## Building the Image

### Using Docker Compose (Recommended)

To build the Docker image using Docker Compose, run:

```sh
docker-compose build
```

### Using Docker Build

Alternatively, you can build the image directly using Docker:

```sh
docker build -t step_bible_docker .
```

## Running the Container

### Using Docker Compose (Recommended)

To start the container in detached mode:

```sh
docker-compose up -d
```

To stop the container:

```sh
docker-compose down
```

### Using Docker Run

If you prefer to run the container directly using Docker:

```sh
docker run -it --rm -p 8989:8989 -v ${HOME}/.sword:/home/step/.sword step_bible_docker
```

## Key Features

- **Automatic Download**: The Dockerfile automatically downloads the latest version of StepBible from the official website. No manual intervention is required.
- **Virtual Display**: The `entrypoint.sh` script sets up a virtual display using Xvfb, enabling graphical applications to run in a headless Docker environment.
- **Persistent Storage**: The container mounts your local `.sword` directory to store Bible modules persistently.
- **Easy Management**: The Docker Compose configuration simplifies container lifecycle management.

## Accessing the Application

Once the container is running, you can access the StepBible application by navigating to:

- **Local Access**: `http://localhost:8989`
- **Remote Access**: Replace `localhost` with the IP address of the host machine where the container is running.

## Notes

- Ensure your local `.sword` directory exists before running the container to avoid permission issues.
- The application will be accessible on port `8989` by default.
- The container runs as a non-root user (`step`) for security purposes.
