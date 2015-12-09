FROM linuxserver/baseimage
MAINTAINER sparklyballs <sparklyballs@linuxserver.io> Gonzalo Peci <davyjones@linuxserver.io>


ENV BUILD_APTLIST="autoconf automake build-essential libicu-dev make pkg-config swig3.0 tcl8.6-dev"
ENV APTLIST="--no-install-recommends git-core libperl-dev libpython3-dev libsasl2-dev libssl-dev python3-dev libicu52 libperl5.18 tcl8.6"

# Install build packages
RUN echo "deb http://archive.ubuntu.com/ubuntu/ trusty-backports main restricted universe multiverse" >> /etc/apt/sources.list && \
echo "deb-src http://archive.ubuntu.com/ubuntu/ trusty-backports main restricted universe multiverse" >> /etc/apt/sources.list && \
apt-get update -q && \
apt-get install \
$BUILD_APTLIST \
$APTLIST -qy && \

# build ZNC from git
git clone https://github.com/znc/znc.git --recursive /tmp/znc && \

cd /tmp/znc && \
git clean -xdf && \
./autogen.sh && \
./configure \
--enable-cyrus \
--enable-python \
--enable-swig \
--enable-tcl \
--enable-perl \
--disable-ipv6 && \
make && \
make install && \

# add zncstrap
git clone https://github.com/ProjectFirrre/zncstrap/ /tmp/zncstrap && \
cd /tmp/zncstrap && \
git checkout dev && \

rm -Rf /usr/local/share/znc/webskins && \
rm -Rf /usr/local/share/znc/modules && \
mv webskins /usr/local/share/znc/ && \
mv modules /usr/local/share/znc/ && \

# clean up temporary build dependencies and install runtime deps
apt-get purge --remove \
$BUILD_APTLIST -y && \
apt-get autoremove -y && \
apt-get install \
$APTLIST -qy && \

# clean up
apt-get clean && rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

# Adding Custom files
ADD defaults/ /defaults/
ADD init/ /etc/my_init.d/
ADD services/ /etc/service/
RUN chmod -v +x /etc/service/*/run /etc/my_init.d/*.sh

# Volums and Ports
VOLUME /config
EXPOSE 6501

