FROM lsiobase/alpine
MAINTAINER sparklyballs

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"

# package version
ARG ZNC_VER="latest"

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
	git \
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
	"http://znc.in/nightly/znc-${ZNC_VER}.tar.gz" && \
 tar xf /tmp/znc-src.tar.gz -C \
	/tmp/znc --strip-components=1 && \

# configure and compile znc
 cd /tmp/znc && \
 export CFLAGS="$CFLAGS -D_GNU_SOURCE" && \
 ./configure \
	--build=$CBUILD \
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
	--sysconfdir=/etc && \
 make && \
 make install && \

# determine build packages to keep
 RUNTIME_PACKAGES="$( \
	scanelf --needed --nobanner /usr/bin/znc \
	| awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
	| sort -u \
	| xargs -r apk info --installed \
	| sort -u \
	)" && \
 apk add --no-cache \
	${RUNTIME_PACKAGES} \
	ca-certificates && \

# cleanup
 apk del --purge \
	build-dependencies && \
 rm -rf \
	/tmp/*

# add local files
COPY /root /

# ports and volumes
EXPOSE 6501
VOLUME /config
