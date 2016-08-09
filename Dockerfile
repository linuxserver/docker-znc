FROM lsiobase/alpine
MAINTAINER sparklyballs

# package version
ARG ZNC_VER="2016-08-01"
ARG ZNC_BRANCH="nightly"

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
	/tmp/znc && \
 curl -o \
 /tmp/znc-src.tar.gz -L \
	"http://znc.in/${ZNC_BRANCH}/znc-git-${ZNC_VER}.tar.gz" && \
 tar xf /tmp/znc-src.tar.gz -C \
	/tmp/znc --strip-components=1 && \

# configure and compile znc
 cd /tmp/znc && \
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
