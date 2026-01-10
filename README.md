[![STEP Bible Logo](https://www.stepbible.org/step.png)](https://www.stepbible.org/)

STEP Bible is a free Bible study software for Windows, Mac, and Linux. It provides powerful search and study tools, including Greek/Hebrew lexicons, interlinear Bibles, and support for multiple languages and versions.

# STEP Bible Docker

A Docker setup for running STEP Bible, a graphical Bible study application, in a containerized environment with virtual display support for headless operation.

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

4. **Access STEP Bible** at `http://localhost:8989`.

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

- **Predefined Version**: Uses a specific, tested version of STEP Bible with hash verification (defined in the Dockerfile).
- **Virtual Display**: Uses Xvfb for graphical rendering in headless environments.
- **Persistent Storage**: Mounts local `.sword` directory for Bible modules.
- **Secure**: Runs as non-root user.
- **Network Access**: Accessible over Docker bridge network without errors.

## Access

- **Local**: `http://localhost:8989`
- **Remote**: `http://<host-ip>:8989`
- **From other containers**: `http://stepbible:8989`

## Reverse Proxy Configuration (Nginx)

When running STEP Bible behind an Nginx reverse proxy (like SWAG), you must ensure that forwarded headers are correctly set and that the non-standard MIME types used by the application are handled.

Add the following to your Nginx location block:

```nginx
location / {
    # Standard proxy settings
    include /config/nginx/proxy.conf;
    include /config/nginx/resolver.conf;
    set $upstream_app stepbible;
    set $upstream_port 8989;
    set $upstream_proto http;
    proxy_pass $upstream_proto://$upstream_app:$upstream_port;

    # FIX: Override the incorrect 'text/js' MIME type from the backend
    # This is required for modern browsers to execute the localization scripts
    proxy_hide_header Content-Type;
    add_header Content-Type $upstream_http_content_type;
    if ($request_uri ~* \.js$) {
        add_header Content-Type "application/javascript; charset=UTF-8" always;
    }

    # Required headers for STEP Bible
    proxy_set_header X-Forwarded-Port $server_port;
    proxy_set_header Accept-Encoding "";
    proxy_buffering off;
}
```

## Updating STEP Bible

To update the version of STEP Bible used in this Docker image:

1.  **Run the update script** to find the latest version and its SHA256 hash:
    ```bash
    bash scripts/get_latest_stepbible_deb.sh
    ```

2.  **Update the `Dockerfile`** with the new values for `STEP_VERSION` and `STEP_HASH`.

3.  **Rebuild the image**:
    ```bash
    docker-compose build --no-cache
    ```

## Notes

- Ensure `${HOME}/.sword` exists to avoid permission issues.
- Default port: 8989.
- For remote access, use the host machine's IP.

## Acknowledgements

Official STEP repository: [STEPBible/step](https://github.com/STEPBible/step)

Based on the work by [PJonathas](https://github.com/PJonathas/STEP BibleDocker).
