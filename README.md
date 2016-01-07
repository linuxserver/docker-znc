![https://linuxserver.io](https://www.linuxserver.io/wp-content/uploads/2015/06/linuxserver_medium.png)

The [LinuxServer.io](https://www.linuxserver.io/) team brings you another quality container release featuring auto-update of dependencies on startup, easy user mapping and community support. Be sure to checkout our [forums](https://forum.linuxserver.io/index.php) or for real-time support our [IRC](https://www.linuxserver.io/index.php/irc/) on freenode at `#linuxserver.io`.

# lsiodev/znc

![](http://wiki.znc.in/resources/assets/wiki.png)

[ZNC](http://wiki.znc.in/ZNC)  is an IRC network bouncer or BNC. It can detach the client from the actual IRC server, and also from selected channels. Multiple clients from different locations can connect to a single ZNC account simultaneously and therefore appear under the same nickname on IRC.

## Usage

```
docker create \
  --name=znc \
  -v /etc/localtime:/etc/localtime:ro \
  -v <path to data>:/config \
  -e PGID=<gid> -e PUID=<uid>  \
  -p 6501:6501 \
  lsiodev/znc
```

**Parameters**

* `-p 6501` - the port(s)
* `-v /etc/localtime` for timesync - *optional*
* `-v /config` -
* `-e PGID` for GroupID - see below for explanation
* `-e PUID` for UserID - see below for explanation

It is based on phusion-baseimage with ssh removed, for shell access whilst the container is running do `docker exec -it znc /bin/bash`.

* To monitor the logs of the container in realtime `docker logs -f znc`.

### User / Group Identifiers

**TL;DR** - The `PGID` and `PUID` values set the user / group you'd like your container to 'run as' to the host OS. This can be a user you've created or even root (not recommended).

Part of what makes our containers work so well is by allowing you to specify your own `PUID` and `PGID`. This avoids nasty permissions errors with relation to data volumes (`-v` flags). When an application is installed on the host OS it is normally added to the common group called users, Docker apps due to the nature of the technology can't be added to this group. So we added this feature to let you easily choose when running your containers.

## Setting up the application

To log in to the application, browse to https://<hostip>:6501.

* Default User: admin
* Default Password: admin
Please change this value ASAP.

## Versions

+ **11.12.2015:** Initial Release.
