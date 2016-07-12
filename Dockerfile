FROM lsiobase/alpine
MAINTAINER sparklyballs

# package version
ARG ZNC_VER="git-2016-07-09"
ARG ZNC_BRANCH="nightly"

# environment settings
ARG ZNC_ROOT="/tmp/source"
ARG ZNC_SRC="${ZNC_ROOT}/znc"
ARG ZNC_URL="http://znc.in"
ARG ZNC_WWW="${ZNC_URL}/${ZNC_BRANCH}/znc-${ZNC_VER}.tar.gz"

# install build packages
RUN \
 apk add --no-cache --virtual=build-dependencies \
	autoconf \
	automake \
	c-ares-dev \
	curl \
	cyrus-sasl-dev \
	g++ \
	gcc \
	gettext-dev \
	icu-dev \
	make \
	openssl-dev \
	perl-dev \
	python3-dev \
	swig \
	tar \
	tcl-dev && \

# fetch and unpack source
 mkdir -p \
	"${ZNC_SRC}" && \
 curl -o \
 "${ZNC_ROOT}/znc.tar.gz" -L \
	"${ZNC_WWW}" && \
 tar xf "${ZNC_ROOT}/znc.tar.gz" -C \
	"${ZNC_SRC}" --strip-components=1 && \

# configure and compile znc
 cd "${ZNC_SRC}" && \
 export CFLAGS="$CFLAGS -D_GNU_SOURCE" && \
 ./configure \
	--build=$CBUILD \
	--disable-ipv6 \
	--enable-cyrus \
	--enable-perl \
	--enable-python \
	--enable-swig \
	--enable-tcl \
	--host=$CHOST \
	--infodir=/usr/share/info \
	--localstatedir=/var \
	--mandir=/usr/share/man \
	--prefix=/usr \
	--sysconfdir=/etc \
 make && \
 make install && \

# cleanup
 apk del --purge \
	build-dependencies && \
 rm -rf \
	/tmp/*

# install runtime packages
RUN \
 apk add --no-cache \
	icu-libs

# add local files
COPY /root /

# ports and volumes
EXPOSE 6501
VOLUME /config
