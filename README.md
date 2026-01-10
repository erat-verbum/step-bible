[![StepBible Logo](https://www.stepbible.org/step.png)](https://www.stepbible.org/)

StepBible is a free Bible study software for Windows, Mac, and Linux. It provides powerful search and study tools, including Greek/Hebrew lexicons, interlinear Bibles, and support for multiple languages and versions.

# StepBible Docker

A Docker setup for running StepBible, a graphical Bible study application, in a containerized environment with virtual display support for headless operation.

## Prerequisites

- Docker
- Docker Compose (recommended)

## Quick Start

1. **Clone or download** this repository.

2. **Build the image**:
   ```bash
   docker-compose build
   ```

3. **Run the container**:
   ```bash
   docker-compose up -d
   ```

4. **Access StepBible** at `http://localhost:8989`.

## Manual Commands

### Building
- **Docker Compose**:
  ```bash
  docker-compose build
  ```
- **Docker Build**:
  ```bash
  docker build -t step_bible_docker .
  ```

### Running
- **Docker Compose**:
  ```bash
  docker-compose up -d  # Start
  docker-compose down   # Stop
  ```
- **Docker Run**:
  ```bash
  docker run -it --rm -p 8989:8989 -v ${HOME}/.sword:/home/step/.sword step_bible_docker
  ```

## Features

- **Automatic Download**: Downloads the latest StepBible version from the official site.
- **Virtual Display**: Uses Xvfb for graphical rendering in headless environments.
- **Persistent Storage**: Mounts local `.sword` directory for Bible modules.
- **Secure**: Runs as non-root user.
- **Network Access**: Accessible over Docker bridge network without errors.

## Access

- **Local**: `http://localhost:8989`
- **Remote**: `http://<host-ip>:8989`
- **From other containers**: `http://stepbible:8989`

## Notes

- Ensure `${HOME}/.sword` exists to avoid permission issues.
- Default port: 8989.
- For remote access, use the host machine's IP.

## Acknowledgements

Based on the work by [PJonathas](https://github.com/PJonathas/StepBibleDocker).