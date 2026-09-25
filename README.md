<h1 align="center">SS14.Watchdog.Docker</h1>

<p align="center">
  Containerized deployment of the <a href="https://spacestation14.com/">Space Station 14</a> watchdog on Linux.
</p>

<div align="center">

[![Create and publish a Docker image](https://github.com/lever1209/SS14.Watchdog.Docker/actions/workflows/main.yml/badge.svg?branch=main)](https://github.com/lever1209/SS14.Watchdog.Docker/actions/workflows/main.yml)

</div>


### Overview

This project is for those who prefer containerized solutions. It's based on the [official documentation](https://docs.spacestation14.com/en/server-hosting/setting-up-ss14-watchdog.html) but wrapped up in a Docker container for convenience.

### Quick Start

1. **Clone the repository**

    ```bash
    git clone https://github.com/lever1209/SS14.Watchdog.Docker.git && cd SS14.Watchdog.Docker
    ```

2. **Configure Your Server**

    This will require more effort than the previous version of this container.

    You must mount a volume or host directory at /config and place the following inside:
    
    `/config/instances/NameOfInstance/config.toml` -- This is the server_config.toml file for that specific instance, you may have any number of instances with their own configurations

    `/config/data.db` -- This is a simple SQLite Database that contains persistent information for the watchdog (currently it just states UUIDs for each instance for internal use i assume)
    
    `/config/appsettings.yml` -- This is largely unchanged from before, it is the main configuration file for SS14.Watchdog, any instances you create inside must have their directories created above and should probably have a `config.toml` placed inside that

    Remember to forward your ports, 5000 is for talking with the watchdog directly, 1212 is the default port for ss14 servers, and if you host more than one server you will need to change its default port info in `appsettings.yml` and its respective `config.toml`

    See [[./Examples/README.md]] for more information, as well as different kinds of deployments. (Currently unimplemented, sorry!)

3. **Run the Server**

    Using Docker directly:

    ```bash
    docker run --rm -d \
      -p 5000:5000 \
      -p 1212:1212/tcp \
      -p 1212:1212/udp \
      --mount type=bind,src=/path/to/config,dst=/config \
      ghcr.io/lever1209/ss14.watchdog.docker:main
    ```

    Or using Docker Compose:

    First, create a `docker-compose.yml` file:

    ```yaml
    version: '3'

    services:
      ss14-watchdog:
        image: ghcr.io/lever1209/ss14.watchdog.docker:main
        ports:
          - "1212:1212/tcp"
          - "1212:1212/udp"
          - "5000:5000/tcp"
        volumes:
          - /path/to/config:/config
        restart: always
    ```

    Then, run with:

    ```bash
    docker-compose up -d
    ```

---
