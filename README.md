[![linuxserver.io](https://raw.githubusercontent.com/linuxserver/docker-templates/master/linuxserver.io/img/linuxserver_medium.png)](https://linuxserver.io)

The [LinuxServer.io](https://linuxserver.io) team brings you another container release featuring :-

 * regular and timely application updates
 * easy user mappings (PGID, PUID)
 * custom base image with s6 overlay
 * weekly base OS updates with common layers across the entire LinuxServer.io ecosystem to minimise space usage, down time and bandwidth
 * regular security updates

Find us at:
* [Discord](https://discord.gg/YWrKVTn) - realtime support / chat with the community and the team.
* [IRC](https://irc.linuxserver.io) - on freenode at `#linuxserver.io`. Our primary support channel is Discord.
* [Blog](https://blog.linuxserver.io) - all the things you can do with our containers including How-To guides, opinions and much more!

# [linuxserver/znc](https://github.com/linuxserver/docker-znc)
[![](https://img.shields.io/discord/354974912613449730.svg?logo=discord&label=LSIO%20Discord&style=flat-square)](https://discord.gg/YWrKVTn)
[![](https://images.microbadger.com/badges/version/linuxserver/znc.svg)](https://microbadger.com/images/linuxserver/znc "Get your own version badge on microbadger.com")
[![](https://images.microbadger.com/badges/image/linuxserver/znc.svg)](https://microbadger.com/images/linuxserver/znc "Get your own version badge on microbadger.com")
![Docker Pulls](https://img.shields.io/docker/pulls/linuxserver/znc.svg)
![Docker Stars](https://img.shields.io/docker/stars/linuxserver/znc.svg)
[![Build Status](https://ci.linuxserver.io/buildStatus/icon?job=Docker-Pipeline-Builders/docker-znc/master)](https://ci.linuxserver.io/job/Docker-Pipeline-Builders/job/docker-znc/job/master/)
[![](https://lsio-ci.ams3.digitaloceanspaces.com/linuxserver/znc/latest/badge.svg)](https://lsio-ci.ams3.digitaloceanspaces.com/linuxserver/znc/latest/index.html)

[Znc](http://wiki.znc.in/ZNC) is an IRC network bouncer or BNC. It can detach the client from the actual IRC server, and also from selected channels. Multiple clients from different locations can connect to a single ZNC account simultaneously and therefore appear under the same nickname on IRC.

[![znc](http://wiki.znc.in/resources/assets/wiki.png)](http://wiki.znc.in/ZNC)

## Supported Architectures

Our images support multiple architectures such as `x86-64`, `arm64` and `armhf`. We utilise the docker manifest for multi-platform awareness. More information is available from docker [here](https://github.com/docker/distribution/blob/master/docs/spec/manifest-v2-2.md#manifest-list) and our announcement [here](https://blog.linuxserver.io/2019/02/21/the-lsio-pipeline-project/). 

Simply pulling `linuxserver/znc` should retrieve the correct image for your arch, but you can also pull specific arch images via tags.

The architectures supported by this image are:

| Architecture | Tag |
| :----: | --- |
| x86-64 | amd64-latest |
| arm64 | arm64v8-latest |
| armhf | arm32v7-latest |


## Usage

Here are some example snippets to help you get started creating a container.

### docker

```
docker create \
  --name=znc \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=Europe/London \
  -p 6501:6501 \
  -v <path to data>:/config \
  --restart unless-stopped \
  linuxserver/znc
```


### docker-compose

Compatible with docker-compose v2 schemas.

```
---
version: "2"
services:
  znc:
    image: linuxserver/znc
    container_name: znc
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Europe/London
    volumes:
      - <path to data>:/config
    ports:
      - 6501:6501
    restart: unless-stopped
```

## Parameters

Container images are configured using parameters passed at runtime (such as those above). These parameters are separated by a colon and indicate `<external>:<internal>` respectively. For example, `-p 8080:80` would expose port `80` from inside the container to be accessible from the host's IP on port `8080` outside the container.

| Parameter | Function |
| :----: | --- |
| `-p 6501` | Port ZNC listens on. |
| `-e PUID=1000` | for UserID - see below for explanation |
| `-e PGID=1000` | for GroupID - see below for explanation |
| `-e TZ=Europe/London` | Specify a timezone to use EG Europe/London. |
| `-v /config` | Where local ZNC data is stored. |

## User / Group Identifiers

When using volumes (`-v` flags) permissions issues can arise between the host OS and the container, we avoid this issue by allowing you to specify the user `PUID` and group `PGID`.

Ensure any volume directories on the host are owned by the same user you specify and any permissions issues will vanish like magic.

In this instance `PUID=1000` and `PGID=1000`, to find yours use `id user` as below:

```
  $ id username
    uid=1000(dockeruser) gid=1000(dockergroup) groups=1000(dockergroup)
```


&nbsp;
## Application Setup

To log in to the application, browse to https://<hostip>:6501.

* Default User: admin
* Default Password: admin
`change password ASAP.`



## Support Info

* Shell access whilst the container is running: `docker exec -it znc /bin/bash`
* To monitor the logs of the container in realtime: `docker logs -f znc`
* container version number 
  * `docker inspect -f '{{ index .Config.Labels "build_version" }}' znc`
* image version number
  * `docker inspect -f '{{ index .Config.Labels "build_version" }}' linuxserver/znc`

## Updating Info

Most of our images are static, versioned, and require an image update and container recreation to update the app inside. With some exceptions (ie. nextcloud, plex), we do not recommend or support updating apps inside the container. Please consult the [Application Setup](#application-setup) section above to see if it is recommended for the image.  
  
Below are the instructions for updating containers:  
  
### Via Docker Run/Create
* Update the image: `docker pull linuxserver/znc`
* Stop the running container: `docker stop znc`
* Delete the container: `docker rm znc`
* Recreate a new container with the same docker create parameters as instructed above (if mapped correctly to a host folder, your `/config` folder and settings will be preserved)
* Start the new container: `docker start znc`
* You can also remove the old dangling images: `docker image prune`

### Via Taisun auto-updater (especially useful if you don't remember the original parameters)
* Pull the latest image at its tag and replace it with the same env variables in one shot:
  ```
  docker run --rm \
  -v /var/run/docker.sock:/var/run/docker.sock taisun/updater \
  --oneshot znc
  ```
* You can also remove the old dangling images: `docker image prune`

### Via Docker Compose
* Update all images: `docker-compose pull`
  * or update a single image: `docker-compose pull znc`
* Let compose update all containers as necessary: `docker-compose up -d`
  * or update a single container: `docker-compose up -d znc`
* You can also remove the old dangling images: `docker image prune`

## Versions

* **23.03.19:** - Switching to new Base images, shift to arm32v7 tag.
* **22.02.19:** - Rebasing to alpine 3.9.
* **31.01.19:** - Add pipeline logic and multi arch.
* **30.01.19:** - Add push and clientbuffer modules.
* **17.08.18:** - Rebase to alpine 3.8, use buildstage.
* **03.01.18:** - Deprecate cpu_core routine lack of scaling.
* **07.12.17:** - Rebase alpine linux 3.7.
* **25.10.17:** - Remove debug switch from run command.
* **26.05.17:** - Rebase alpine linux 3.6.
* **06.02.17:** - Rebase alpine linux 3.5.
* **19.01.17:** - Add playback module.
* **07.01.17:** - Add ca-certificates package, resolve sasl issues.
* **07.12.16:** - Use scanelf to determine runtime dependencies. Fix error with continuation.
* **14.10.16:** - Add version layer information.
* **30.09.16:** - Fix umask.
* **11.09.16:** - Add layer badges to README.
* **28.08.16:** - Add badges to README.
* **20.08.16:** - Rebase to alpine linux, move to main repository.
* **11.12.15:** - Initial Release.
