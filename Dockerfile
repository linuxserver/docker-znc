FROM linuxserver/baseimage
MAINTAINER Mark Burford  <sparklyballs@gmail.com>
ENV DEBIAN_FRONTEND noninteractive
ENV HOME /root
ENV TERM screen


#Applying stuff
ADD excludes /etc/dpkg/dpkg.cfg.d/excludes
RUN echo "deb http://archive.ubuntu.com/ubuntu/ trusty-backports main restricted universe multiverse" >> /etc/apt/sources.list && \
echo "deb-src http://archive.ubuntu.com/ubuntu/ trusty-backports main restricted universe multiverse" >> /etc/apt/sources.list && \
apt-get update -qq && \
# define configure options as a variable
configOPTS="--enable-cyrus \
--enable-python \
--enable-swig \
--enable-tcl \
--enable-perl \
--disable-ipv6" && \

# define temporary build dependencies as a variable
buildDepsTemp="build-essential \
pkg-config \
make \
autoconf \
automake \
tcl8.6-dev \
libicu-dev \
swig3.0" && \

# define permanent build dependencies as a variable
buildDepsPerm="git-core \
python3-dev \
libpython3-dev \
libsasl2-dev \
libssl-dev \
libperl-dev" && \

# define runtime dependencies as a variable
runtimeDeps="tcl8.6 \
supervisor \
libicu52 \
libperl5.18" && \

# install build dependencies
apt-get install \
--no-install-recommends \
$buildDepsTemp \
$buildDepsPerm  -qy && \

# build ZNC from git
cd /tmp && \
git clone https://github.com/znc/znc.git --recursive && \

cd /tmp/znc && \
git clean -xdf && \
./autogen.sh && \
./configure \
$configOPTS && \
make && \
make install && \

# clean up temporary build dependencies and install runtime deps
apt-get purge --remove \
$buildDepsTemp -y && \
apt-get autoremove -y && \
apt-get install \
--no-install-recommends \
$buildDepsPerm \
$runtimeDeps -qy && \

apt-get clean && rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

#Adding Custom files
RUN mkdir /defaults 
ADD init/ /etc/my_init.d/
ADD defaults/ /defaults/
RUN chmod -v +x /etc/service/*/run && chmod -v +x /etc/my_init.d/*.sh

#Adding abc user
RUN useradd -u 911 -U -s /bin/false abc && usermod -G users abc

# Use baseimage-docker's init system
CMD ["/sbin/my_init"]

# Volums and Ports
VOLUME /config
EXPOSE 6501


