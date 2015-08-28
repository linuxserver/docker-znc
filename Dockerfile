FROM linuxserver/baseimage
MAINTAINER Mark Burford  <sparklyballs@gmail.com>

#Applying stuff
ADD excludes /etc/dpkg/dpkg.cfg.d/excludes
RUN apt-get update -qq && \
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
# add zncstrap
git clone https://github.com/ProjectFirrre/zncstrap/ /zncstrap && \
cd "/zncstrap" && \
git checkout dev && \

rm -Rf /usr/local/share/znc/webskins && \
rm -Rf /usr/local/share/znc/modules && \
mv webskins /usr/local/share/znc/ && \
mv modules /usr/local/share/znc/ && \

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
ADD init/ /etc/my_init.d/
ADD services/ /etc/service/
RUN chmod -v +x /etc/service/*/run
RUN chmod -v +x /etc/my_init.d/*.sh
RUN mkdir /defaults
ADD defaults/ /defaults/

# Use baseimage-docker's init system
CMD ["/sbin/my_init"]

# Volums and Ports
VOLUME /config
EXPOSE 6501
